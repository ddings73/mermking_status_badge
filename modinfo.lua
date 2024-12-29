name = "Mermking Status Badge(BETA)"
description = "어인왕의 체력과 배고픔 수치를 보여줍니다. \n 어인왕이 동굴과 지상 양쪽에 모두 위치할 경우, 현재 플레이어가 위치하는 세계의 어인왕 정보만 표시됩니다. \n\n 옵션을 통해 어인왕의 수치를 볼 수 있는 캐릭터 범위를 조절할 수 있습니다."
author = "ddings"
version = "0.1.0"
forumthread = ""

icon_atlas = "modicon.xml"
icon = "modicon.tex"

all_clients_require_mod = true
client_only_mod = false

dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false
dst_compatible = true

api_version = 10


configuration_options =
{
    {
        name = "VISIBLEOPTION",
        label = "Visible Player",
        hover = "어인왕의 체력 및 허기수치를 보여줄 캐릭터 범위를 설정합니다.",
        options =   {
                        {description = "Merm", data = true},
                        {description = "All", data = false},
                    },
        default = true
    }
}