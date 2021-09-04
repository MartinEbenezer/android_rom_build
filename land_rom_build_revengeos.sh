echo $(date '+%Y-%m-%d %H:%M:%S') ​"Beginning to build RevengeOS for Land"

echo $(date '+%Y-%m-%d %H:%M:%S') ​"Mount SSD : Begin"

lsblk
sudo mkfs.ext4 -F /dev/nvme0n1
sudo mkdir -p /mnt/disks/local/
sudo mount /dev/nvme0n1 /mnt/disks/local/
sudo chmod a+w /mnt/disks/local/
cd /mnt/disks/local/

echo $(date '+%Y-%m-%d %H:%M:%S') ​"Mount SSD : End"

echo $(date '+%Y-%m-%d %H:%M:%S') ​"Build Env Setup : Begin"

git clone https://github.com/rushiranpise/titan
sudo bash titan/gitpod.sh

echo $(date '+%Y-%m-%d %H:%M:%S') ​"Build Env Setup : End"

echo $(date '+%Y-%m-%d %H:%M:%S') ​"Initiate Variables : Begin"

WORK_DIR=revengeos_land
ROM_LINK=https://github.com/RevengeOS/android_manifest
ROM_BRANCH=r11.0
DT=https://github.com/MartinEbenezer/android_device_xiaomi_land
DTB=revengeos
KT=https://github.com/sairam1411/kernel_xiaomi_msm8937
KTB=11.x
VT=https://github.com/sairam1411/vendor_xiaomi_land
VTB=11.x
DEVICE=land
ROM=revengeos

echo $(date '+%Y-%m-%d %H:%M:%S') ​"WORK_DIR            : " ${WORK_DIR}
echo $(date '+%Y-%m-%d %H:%M:%S') ​"ROM_LINK            : " ${ROM_LINK}
echo $(date '+%Y-%m-%d %H:%M:%S') ​"ROM_BRANCH          : " ${ROM_BRANCH}
echo $(date '+%Y-%m-%d %H:%M:%S') ​"DEVICE_TREE_LINK    : " ${DT}
echo $(date '+%Y-%m-%d %H:%M:%S') ​"DEVICE_TREE_BRANCH  : " ${DTB}
echo $(date '+%Y-%m-%d %H:%M:%S') ​"KERNEL_TREE_LINK    : " ${KT}
echo $(date '+%Y-%m-%d %H:%M:%S') ​"KERNEL_TREE_BRANCH  : " ${KTB}
echo $(date '+%Y-%m-%d %H:%M:%S') ​"VENDOR_TREE_LINK    : " ${VT}
echo $(date '+%Y-%m-%d %H:%M:%S') ​"VENDOR_TREE_BRANCH  : " ${VTB}

mkdir ${WORK_DIR} && cd ${WORK_DIR}
git config --global user.email "martinebenezer1112@gmail.com"
git config --global user.name "MartinEbenezer"
git config --global color.ui true
export JAVA_TOOL_OPTIONS=-Xmx25g

echo $(date '+%Y-%m-%d %H:%M:%S') ​"Initiate Variables : End"

echo $(date '+%Y-%m-%d %H:%M:%S') ​"ROM Source Repo Sync : Begin"

repo init -q --no-repo-verify --depth=1 -u ${ROM_LINK} -b ${ROM_BRANCH}
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)

echo $(date '+%Y-%m-%d %H:%M:%S') ​"ROM Source Repo Sync : End"

echo $(date '+%Y-%m-%d %H:%M:%S') ​"Device/Kernel/Vendor Trees Sync : Begin"

git clone --depth 1 ${DT} -b ${DTB} device/xiaomi/land
git clone --depth 1 ${KT} -b ${KTB} kernel/xiaomi/msm8937
git clone --depth 1 ${VT} -b ${VTB} vendor/xiaomi/land

echo $(date '+%Y-%m-%d %H:%M:%S') ​"Device/Kernel/Vendor Trees Sync : End"

echo $(date '+%Y-%m-%d %H:%M:%S') ​"Clone RIL Fix Trees : Begin"

ls vendor/codeaurora/telephony/
rm -Rf vendor/codeaurora/telephony/
git clone --depth 1 https://github.com/ForkLineageOS/android_vendor_codeaurora_telephony -b lineage-18.1 vendor/codeaurora/telephony 

ls frameworks/opt/telephony/
rm -Rf frameworks/opt/telephony/
git clone --depth 1 https://github.com/ForkLineageOS/android_frameworks_opt_telephony -b lineage-18.1 frameworks/opt/telephony 

echo $(date '+%Y-%m-%d %H:%M:%S') ​"Clone RIL Fix Trees : End"

echo $(date '+%Y-%m-%d %H:%M:%S') ​"Clone HALs from DOT Source : Begin"

ls hardware/qcom-caf/msm8996/

rm -Rf hardware/qcom-caf/msm8996/display
rm -Rf hardware/qcom-caf/msm8996/audio
rm -Rf hardware/qcom-caf/msm8996/media

git clone --depth 1 https://github.com/DotOS/android_hardware_qcom_display -b dot11-caf-msm8996 hardware/qcom-caf/msm8996/display
git clone --depth 1 https://github.com/DotOS/android_hardware_qcom_audio -b dot11-caf-msm8996 hardware/qcom-caf/msm8996/audio
git clone --depth 1 https://github.com/DotOS/android_hardware_qcom_media -b dot11-caf-msm8996 hardware/qcom-caf/msm8996/media

echo $(date '+%Y-%m-%d %H:%M:%S') ​"Clone HALs from DOT Source : End"

# Uncomment below line in case of failure
# rm -f device/xiaomi/land/touch/Android.bp

# --Pick below Commits
# --No need for Colt OS

# https://github.com/ForkLineageOS/android_frameworks_base/commit/108d81b8abec967ff5973a52fe7fd745ddbac3c9
# https://github.com/ForkLineageOS/android_frameworks_base/commit/065a9aa0e7d06faefb8e140b84feeea795fa9036

echo $(date '+%Y-%m-%d %H:%M:%S') ​"Build ROM : Begin"

source build/envsetup.sh
lunch ${ROM}_${DEVICE}-userdebug
make bacon -j16

echo $(date '+%Y-%m-%d %H:%M:%S') ​"Build ROM : End"

echo $(date '+%Y-%m-%d %H:%M:%S') ​"ROM Build Completed Successfully"

echo $(date '+%Y-%m-%d %H:%M:%S') ​"Upload ROM : Begin"

cd $OUT
ROM_ZIP_FILE=`find . -name *official*zip`
echo $(date '+%Y-%m-%d %H:%M:%S') ​"ROM Zip File Name : " ${ROM_ZIP_FILE}
curl -# --upload-file ${ROM_ZIP_FILE} https://transfer.sh/

echo $(date '+%Y-%m-%d %H:%M:%S') ​"Upload ROM : End"