#!/bin/bash
source omnienv/bin/activate

if /usr/local/lib/omnissiah/raw_mac.py; then
  /usr/local/lib/omnissiah/info_mac.py
fi
if /usr/local/lib/omnissiah/raw_netbox.py; then
  if /usr/local/lib/omnissiah/info_netbox.py; then
    /usr/local/lib/omnissiah/ref_netbox.py
#    /usr/local/lib/omnissiah/src_netbox.py
  fi
fi
if /usr/local/lib/omnissiah/raw_enplug.py; then
  /usr/local/lib/omnissiah/src_enplug.py
fi
fi /usr/local/lib/omnissiah/raw_activaire.py; then
  /usr/local/lib/omnissiah/src_activaire.py
fi
fi /usr/local/lib/omnissiah/raw_mist.py; then
  /usr/local/lib/omnissiah/src_mist.py
fi
if /usr/local/lib/omnissiah/raw_scan.py; then
  if /usr/local/lib/omnissiah/raw_map.py; then
    /usr/local/lib/omnissiah/raw_snmp.py
    /usr/local/lib/omnissiah/raw_ruckussz.py
    if /usr/local/lib/omnissiah/src_scan.py; then
      if /usr/local/lib/omnissiah/src_snmp.py; then
        /usr/local/lib/omnissiah/src_ruckussz.py
      fi
    fi
  fi
fi
/usr/local/lib/omnissiah/src_addr.py
if /usr/local/lib/omnissiah/nnml_prepare.py; then
  if /usr/local/lib/omnissiah/nnml_label.py; then
    /usr/local/lib/omnissiah/nnml_train.py
  fi
  /usr/local/lib/omnissiah/nnml_predict.py
fi
/usr/local/lib/omnissiah/shot_enplug.py
/usr/local/lib/omnissiah/shot_activaire.py
/usr/local/lib/omnissiah/shot_mist.py
/usr/local/lib/omnissiah/shot_ruckussz.py
/usr/local/lib/omnissiah/shot_wap.py
/usr/local/lib/omnissiah/shot_nnml.py
/usr/local/lib/omnissiah/shot_router.py
/usr/local/lib/omnissiah/shot_host.py
/usr/local/lib/omnissiah/main_addr.py
/usr/local/lib/omnissiah/main_host.py

/usr/local/lib/omnissiah/hist_dump.py
deactivate