add() {
	echo "`wine reg QUERY \"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\" /v PATH`"
    wine_current_reg_path="`wine reg QUERY \"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\" /v PATH | grep REG_EXPAND_SZ | sed 's/^.*REG_EXPAND_SZ\s*//'`"	
    wine_new_reg_path="${1};${wine_current_reg_path}"
    wine reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /t REG_EXPAND_SZ /v PATH /d "${wine_new_reg_path}" /f
    wine_actual_reg_path="`wine reg QUERY \"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\" /v PATH | grep REG_EXPAND_SZ | sed 's/^.*REG_EXPAND_SZ\s*//'`"
	echo "`wine reg QUERY \"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\" /v PATH`"  
}

add "${1}"
