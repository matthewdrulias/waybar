#!/usr/bin/env bash



nmclicmd="nmcli connection"
wgconns="$nmclicmd show"
wgactive="$wgconns --active"

connected=()
available=()

function get_conns {
	while read -r name uuid type device
	do
		if [[ $type != "wireguard" ]]
		then
			continue
		fi

		if [[ $device != "--" ]]
		then
			while read -r key value
			do
				if [[ $key != "ipv4.addresses:" ]]
				then
					continue
				fi
				connected+=("$name: $value")
			done < <($wgconns $name)
		else
			available+=("$name")
		fi
	done < <($1)
}

function print_conns {
	local first="yes"
	local array_print="$1[@]"
	local array_print=("${!array_print}")
	local text=""
	local tooltip=""
    local status=""
	if [ "${#array_print[@]}" -le 0 ]
	then
        echo "Unsecure"
		return
	fi
    for c in "${array_print[@]}"
    do
        if [[ "$first" != "yes" ]]
        then
                text="$text | "
                tooltip="$tooltip\n"
        fi
        text="$text$(echo -n $c | sed -E 's/^(.+): ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9]+)$/\1/')"
        tooltip="$tooltip$c"
        first="no"
    done
    echo $text
}

function vpn {
    get_conns "$wgactive"
    local status=$(print_conns connected "$short")

    if [[ "$status" == "Unsecure" ]]
    then
        chosen=$(printf "Los Angeles\nBoston\nMiami\nDetroit\nSeattle\nDallas" | rofi -dmenu -i -p "WireGuard" -theme-str '@import "artix-ice.rasi"')
        case "$chosen" in
            "Los Angeles") wg-quick up us-lax-wg-101 ;;
            "Boston") wg-quick up us-bos-wg-101 ;;
            "Miami") wg-quick up us-mia-wg-101 ;;
            "Detroit") wg-quick up us-det-wg-001 ;;
            "Seattle") wg-quick up us-sea-wg-101 ;;
            "Dallas") wg-quick up us-dal-wg-502 ;;
            *) exit 1;;
        esac

    else
        chosen=$(printf "Disconnect\nSwitch Servers" | rofi -dmenu -i -p "WireGuard" -theme-str '@import "artix-ice.rasi"')

        case "$chosen" in
            "Disconnect") wg-quick down status ;;
            "Switch Servers") chosen=$(printf "Los Angeles\nBoston\nMiami\nDetroit\nSeattle\nDallas" | rofi -dmenu -i -p "WireGuard" -theme-str '@import "artix-ice.rasi"')
        esac
                                case "$chosen" in
                                    "Los Angeles") wg-quick down "$status" && sleep .5 &&  wg-quick up us-lax-wg-101 ;;
                                    "Boston") wg-quick down "$status" && sleep .5 && wg-quick up us-bos-wg-101 ;;
                                    "Miami") wg-quick down "$status" && sleep .5 && wg-quick up us-mia-wg-101 ;;
                                    "Detroit") wg-quick down "$status" && sleep .5 && wg-quick up us-det-wg-001 ;;
                                    "Seattle") wg-quick down "$status" && sleep .5 && wg-quick up us-sea-wg-101 ;;
                                    "Dallas") wg-quick down "$status" && sleep .5 && wg-quick up us-dal-wg-502 ;;
                                    *) exit 1;;
                                esac
    fi
}

vpn
