#!/bin/sh

######## settings ########
src_path='/path/to/mt/archive/MT-6.3.zip'
app_name='mt'
app_cfg_path='/path/to/mt/mt-config.cgi'

#plugin switch ( 1=Enable, 0=Disable )
FacebookCommenters=1
FormattedText=1
FormattedTextForTinyMCE=1
FormattedTextForTinyMCE5=1
GoogleAnalytics=1
Markdown=1
MultiBlog=1
SmartphoneOption=1
StyleCatcher=1
Textile=1
TinyMCE=1
TinyMCE5=1
WXRImporter=1
WidgetManager=1
feeds_app_lite=1
spamlookup=1
########/settings ########


declare -A default_files=(
    #ActivityFeedscript
    ["activityfeedscript"]="mt-feed.cgi"
    #Adminscript
    ["adminscript"]="mt.cgi"
    #Atomscript
    ["atomscript"]="mt-atom.cgi"
    #Checkscript
    ["checkscript"]="mt-check.cgi"
    #Commentscript
    ["commentscript"]="mt-comments.cgi"
    #Communityscript
    ["communityscript"]="mt-cp.cgi"
    #DataAPIscript
    ["dataapiscript"]="mt-data-api.cgi"
    #Notifyscript
    ["notifyscript"]="mt-add-notify.cgi"
    #Searchscript
    ["searchscript"]="mt-search.cgi"
    #SmartphoneAdminScript
    ["smartphoneadminscript"]="mt-sp.cgi"
    #Trackbackscript
    ["trackbackscript"]="mt-tb.cgi"
    #Upgradescript
    ["upgradescript"]="mt-upgrade.cgi"
    #Viewscript
    ["viewscript"]="mt-view.cgi"
    #XMLRPCscript
    ["xmlrpcscript"]="mt-xmlrpc.cgi"
)

declare -a default_plugins=(
    #MT 6.7.1 over
    "FacebookCommenters"
    "FormattedText"
    "FormattedTextForTinyMCE"
    "FormattedTextForTinyMCE5"
    "GoogleAnalytics"
    "Markdown"
    "MultiBlog"
    "SmartphoneOption"
    "StyleCatcher"
    "Textile"
    "TinyMCE"
    "TinyMCE5"
    "WXRImporter"
    "WidgetManager"
    "feeds-app-lite"
    "spamlookup"
)

mt_dir="${src_path##*/}"
mt_dir="${mt_dir%.zip}"

if [ -d "${mt_dir}" ]; then
    echo "Error : already ${mt_dir}" 
    exit
fi

if [ -d "${app_name}" ]; then
    echo "Error : already ${app_name}" 
    exit
fi

if [ "${1}" ]; then
    verbose='-v'
fi

if [ "${verbose}" ]; then
    echo "Start ..."
fi

if [ -f "${src_path}" ];then
    if [ "${verbose}" ]; then
        echo "Unzip ${mt_dir} ..."
    fi
    unzip -q ${src_path}
else
    echo "Error : not found ${src_path}"
    exit
fi

if [ "${verbose}" ]; then
    echo "Making ${app_name} ..."
fi
mv ${verbose} ${mt_dir} ${app_name}

if [ -d "${app_name}" ]; then
    chmod ${verbose} 644 ${app_name}/tools/*

    mkdir ${verbose} -p ${app_name}/_cgi
    mv ${verbose} ${app_name}/mt-testbg.cgi ${app_name}/_cgi/
    mv ${verbose} ${app_name}/mt-config.cgi-original ${app_name}/_cgi/

    if [ -f "${app_cfg_path}" ]; then
        cp ${verbose} ${app_cfg_path} ${app_name}/
        if [ -f "${app_name}/mt-config.cgi" ]; then
            cat ${app_name}/mt-config.cgi | while read key val
            do
                if [ "${key}" ]; then
                    if [ "${default_files["${key,,}"]}" ]; then
                        if [ -f "${app_name}/${default_files["${key,,}"]}" ]; then
                            if [ "${val}" != 0 ]; then
                                mv ${verbose} ${app_name}/${default_files["${key,,}"]} ${app_name}/${val}
                            else
                                mv ${verbose} ${app_name}/${default_files["${key,,}"]} ${app_name}/_cgi/
                            fi
                        fi
                    fi
                fi
            done
        fi
    fi

    mkdir ${verbose} -p ${app_name}/plugins_disabled
    for plugin in "${default_plugins[@]}"
    do
        eval switch='${'${plugin//-/_}'}'
        if [ "${switch}" != 1 ]; then
            mv ${verbose} ${app_name}/plugins/${plugin} ${app_name}/plugins_disabled/
            if [ "${plugin}" = "SmartphoneOption" ]; then
                if [ -f "${app_name}/${default_files["smartphoneadminscript"]}" ]; then
                    mv ${verbose} ${app_name}/${default_files["smartphoneadminscript"]} ${app_name}/_cgi/
                fi
            fi
        fi
    done

    chmod ${verbose} 600 ${app_name}/_cgi/*
    chmod ${verbose} 700 ${app_name}/_cgi
    chmod ${verbose} 700 ${app_name}/plugins_disabled
fi

if [ "${verbose}" ]; then
    echo "Complete !"
fi

exit

