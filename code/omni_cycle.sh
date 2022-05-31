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
deactivate