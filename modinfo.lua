name = "Mermking Status Badge(BETA)"
description = "어인왕의 체력과 배고픔 수치를 보여줍니다. \n 어인왕이 동굴과 지상 양쪽에 모두 위치할 경우, 현재 플레이어가 위치하는 세계의 어인왕 정보만 표시됩니다. \n\n 옵션을 통해 어인왕의 수치를 볼 수 있는 캐릭터 범위를 조절할 수 있습니다."
author = "ddings"
version = "0.2.4"
forumthread = ""

-- 인게임에서 보여지는 모드 아이콘 정보
icon_atlas = "modicon.xml" -- tex파일 내의 이미지에 대한 영역배치 정보
icon = "modicon.tex" -- 아이콘 파일

all_clients_require_mod = true -- 서버 모드
client_only_mod = false -- 클라이언트 모드

-- 호환여부 체크
dont_starve_compatible = false -- 굶지마 싱글
reign_of_giants_compatible = false  -- 거인의 군림 dlc
shipwrecked_compatible = false -- 난파선 dlc
dst_compatible = true -- 굶지마 투게더

-- API 버전 
-- scripts의 mods.lua 파일에서 확인할 수 있으며, 굶지마 투게더의 경우 10
api_version = 10 

-- 모드 옵션 설정정보
configuration_options =
{
    {
        name = "MERM_ONLY",
        label = "Visible Player",
        hover = "어인왕의 체력 및 허기수치를 보여줄 캐릭터 범위를 설정합니다.",
        options =   {
                        {description = "Merm", data = true},
                        {description = "All", data = false},
                    },
        default = true
    }
}