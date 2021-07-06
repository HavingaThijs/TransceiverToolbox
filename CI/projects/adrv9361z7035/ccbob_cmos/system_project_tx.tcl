set ad_hdl_dir    	[pwd]
set ad_phdl_dir   	[pwd]
set proj_dir		$ad_hdl_dir/projects/adrv9361z7035/ccbob_cmos

source $ad_hdl_dir/projects/scripts/adi_project.tcl 
source $ad_hdl_dir/projects/scripts/adi_board.tcl 

set p_device "xc7z035ifbg676-2L"
adi_project_xilinx adrv9361z7035_ccbob_cmos $proj_dir config_tx.tcl
adi_project_files adrv9361z7035_ccbob_cmos [list \
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/adrv9361z7035/common/adrv9361z7035_constr.xdc" \
  "$ad_hdl_dir/projects/adrv9361z7035/common/adrv9361z7035_constr_cmos.xdc" \
  "$ad_hdl_dir/projects/adrv9361z7035/common/ccbob_constr.xdc" \
  "system_top.v" ]

adi_project_run adrv9361z7035_ccbob_cmos
#source $ad_hdl_dir/library/analog.com_user_axi_ad9361_1.0/axi_ad9361_delay.tcl
# Copy the boot file to the root directory
file copy -force $proj_dir/boot $ad_hdl_dir/boot


