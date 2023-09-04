#!/bin/bash

source omnienv/bin/activate
if ./raw_mac.py; then
  ./info_mac.py
fi
if ./raw_netbox.py; then
  if ./info_netbox.py; then
    ./ref_netbox.py
#    ./src_netbox.py
  fi
fi
if ./raw_enplug.py; then
  ./src_enplug.py
fi
fi ./raw_activaire.py; then
  ./src_activaire.py
fi
if ./raw_mist.py; then
  ./src_mist.py
fi
if ./raw_scan.py; then
  if ./raw_map.py; then
    ./raw_snmp.py
    ./raw_ruckussz.py
    if ./src_scan.py; then
      if ./src_snmp.py; then
        ./src_ruckussz.py
      fi
    fi
  fi
fi
./src_addr.py
if ./nnml_prepare.py; then
  if ./nnml_label.py; then
    ./nnml_train.py
  fi
  ./nnml_predict.py
fi
./shot_enplug.py
./shot_activaire.py
./shot_mist.py
./shot_ruckussz.py
./shot_wap.py
./shot_nnml.py
./shot_router.py
./shot_host.py
./main_addr.py
./main_host.py
./zbx_zbx2omni.py
./zbx_main2zbx.py
./zbx_omni2zbx.py
./zbx_zbx2omni.py
#./zbx_zbx2main.py
./hist_dump.py
deactivate
