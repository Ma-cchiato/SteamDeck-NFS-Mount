# Steam Deck NFS Mounting Guide

이 가이드는 Steam Deck 사용자들이 Steam OS에서 Synology NAS에 NFS 마운트하는 방법을 단계별로 설명합니다. 

Synology NAS의 설정은 [링크](https://gall.dcinside.com/mgallery/board/view/?id=steamdeck&no=8982)의 글을 참고하시어 진행한 후, 아래 가이드를 진행하시면 됩니다.

## 1. 사용자 계정 생성 및 수정
데스크탑 모드로 진입한 후, 신규 사용자를 생성합니다. 아래 예시에서는 `deck2`로 생성하였습니다.

![1](https://user-images.githubusercontent.com/122413511/211694613-fc11aee8-7c80-4a56-bd06-d37731642d43.png)


### /etc/passwd 및 /etc/group 수정
새로운 사용자 계정을 생성한 후, 사용자의 uid, gid를 변경합니다.
예시로 진행되는 사용자의 계정명은 `deck2` 입니다.


아래는 `deck2` 사용자의 uid와 gid를 변경하는 예시 명령어입니다
시놀로지 `guest` 계정의 uid는 1025, gid는 100 이므로 해당 값과 동일하게 설정해줍니다.
```
sudo usermod -u 1025 deck2 && sudo usermod -g 100 deck2
sudo groupmod -g 100 deck2
```

변경이 완료되면 사용자의 uid, gid가 아래와 같이 수정됩니다.

```
sudo nano /etc/passwd

deck2:x:1025:100:~~~~
```
![2](https://user-images.githubusercontent.com/122413511/211694644-762d0216-bf3f-433d-a0cc-8360d5e5c80e.png)


```
sudo nano /etc/group

deck2:x:100:
```
![3](https://user-images.githubusercontent.com/122413511/211694682-e26c8add-ea2d-4f0d-873f-d729ad1d4a22.png)


## 2. 마운트 방식 선택

Steam Deck에서 NFS를 마운트하는 방법에는 두 가지가 있습니다: 스크립트를 사용하는 방식과 `fstab` 파일을 직접 수정하는 방식입니다. 


### 2-A. 스크립트를 사용하는 방식

스크립트를 사용하여 NFS 마운트 및 언마운트를 자동화할 수 있습니다. 이 방법은 스크립트를 통해 NAS 연결 상태를 체크하고, 연결되어 있을 때 자동으로 마운트하며, 연결이 끊어졌을 때 언마운트하는 과정을 포함합니다.


#### 스크립트 실행

스크립트를 사용하여 Steam Deck에서 NFS 마운트를 진행하는 과정은 다음과 같습니다:

1. **스크립트 다운로드**: 먼저, 아래 제공된 링크를 통해 NFS 마운트를 위한 스크립트 파일을 다운로드합니다. 파일이 다운로드 되지 않는 경우, 링크 우클릭>다른 이름으로 링크 저장을 통해 다운로드 할 수 있습니다.
 
   [스크립트 다운로드](https://raw.githubusercontent.com/Ma-cchiato/SteamDeck-NFS-Mount/main/Script/nfs_mount.sh)


   또는 `Konsole`을 실행한 후 아래 명령어를 입력하여 다운로드 할 수 있습니다.

   `/home/deck/NFS` 디렉토리에 `nfs_mount.sh` 파일명으로 다운로드 하는 예시 명령어입니다.
   ```
   curl "https://raw.githubusercontent.com/Ma-cchiato/SteamDeck-NFS-Mount/main/Script/nfs_mount.sh" -o "/home/deck/NFS/nfs_mount.sh"
   ```

3. **스크립트 저장 위치**: 다운로드한 스크립트 파일을 Steam Deck 내 원하는 디렉토리에 저장합니다. 아래 예시에서는, `/home/deck/NFS` 디렉토리에 저장하여 진행하였습니다.

4. **실행 권한 부여**: `Konsole`을 열고, 다운로드한 스크립트 파일에 실행 권한을 부여합니다.
   ```
   chmod +x /home/deck/NFS/nfs_mount.sh
   ```

5. **스크립트 실행**: 스크립트에 실행 권한을 부여한 후, 스크립트를 실행합니다. 스크립트를 실행하려면 다음 명령어를 입력합니다
   ```
   sh /home/deck/NFS/nfs_mount.sh
   ```

6. **스크립트 절차**

   - **기본 디렉토리**: 스크립트에서 생성되는 모든 파일은 아래 디렉토리에 생성됩니다.
     ```
     /home/deck/NFS
     ```

   - **초기 설정**: 스크립트는 처음 실행될 때 설정 파일 (`NFS_settings.sh`)을 확인합니다. 설정 파일이 비어있거나 존재하지 않으면, 사용자에게 WiFi SSID, NFS 서버 IP, 공유 경로 및 마운트 경로에 대한 입력을 요청합니다.

   - **설정 저장**: 사용자가 입력한 설정값은 `NFS_settings.sh` 파일에 저장되며, 이후 스크립트 실행 시 이 파일을 참조하여 작동합니다.

   - **서비스 등록**: 시스템 서비스 (`resume_nfs.service`, `startup_nfs.service`)를 등록하고 시작합니다. 이 서비스들은 시스템의 상태 변화(예: 슬립 해제, 시스템 부팅)에 따라 스크립트를 자동으로 실행하여 마운트 여부를 결정합니다.

   - **네트워크 상태 확인 및 마운트 실행**: 스크립트는 현재 Steam Deck이 `NFS_settings.sh` 파일에 설정된 WiFi 네트워크에 연결되어 있는지 확인하고, 연결되어 있다면 NFS 서버에 마운트를 시도합니다. 연결되어 있지 않다면 마운트를 시도하지 않습니다.

   - **마운트 상태 기록 및 확인**: 마운트 성공 또는 실패 여부는 로그 파일 (`NFS_log.log`)에 기록됩니다. 사용자는 이 로그 파일을 통해 마운트 과정의 상세한 내용을 확인할 수 있습니다.

스크립트 실행 후, 마운트가 정상적으로 수행되었는지 확인하기 위해 마운트된 폴더에 접근하거나 `df -h` 또는 `mount` 명령어로 마운트 상태를 확인할 수 있습니다.


### 2-B. fstab 파일 수정 방식

`fstab` 파일을 직접 수정하여 NFS 마운트를 설정할 수 있습니다.

#### NFS 마운트 폴더 생성

NAS와 로컬의 폴더를 매핑하는데 사용할 폴더를 생성합니다. 본인이 원하는 폴더명으로 생성하시면 됩니다.
```
sudo mkdir /run/media/testnfs
```

![4](https://user-images.githubusercontent.com/122413511/211694749-2d2acf90-6e31-437f-bfb7-9885a6cf46bd.png)


#### fstab 수정

`fstab` 파일을 백업하고 수정합니다.
```
sudo nano /etc/fstab
```

파일의 마지막 줄에 다음 내용을 추가합니다. 파일의 IP 및 마운트 경로는 본인의 환경에 맞게 입력하시면 됩니다.
작성 완료 후 수정 사항을 저장하고 나옵니다. (F3 > Enter > F2)
```
192.168.0.5:/volume1/testDeckNFS /run/media/testnfs nfs nfsvers=4,x-systemd.automount,soft,_netdev,retrans=2 0 0
```

![5](https://user-images.githubusercontent.com/122413511/211694751-344cedb5-e6dd-4ac0-8a57-277aa680fbbb.png)


## 3. 마운트 테스트

`mount -a` 명령을 사용하여 수정한 fstab이 정상적으로 작동하는지 테스트합니다.
```
sudo mount -a
```

정상적으로 마운트되면, Dolphin 파일 뷰어의 Remote 영역에 마운트된 폴더가 표시됩니다.


![6](https://user-images.githubusercontent.com/122413511/211694752-58d74a4e-a36e-438b-a865-dc47bb1524cf.png)


테스트를 위해 NFS 드라이브로 임의의 파일을 이동한 후 파일 권한을 확인합니다.

파일 권한을 확인하려면 파일을 마우스 오른쪽 버튼으로 클릭한 후 '속성(Properties)'을 선택합니다. '권한(Permissions)' 탭에서 사용자와 그룹 정보를 확인할 수 있습니다.


![파일 권한 확인](https://user-images.githubusercontent.com/122413511/211694754-208d2126-2f1c-4ea9-829c-d7c05a2e14b2.png)

- **사용자(User)**: deck2
- **그룹(Group)**: deck2

이 단계에서 사용자와 그룹 이름이 `deck2`로 표시된다면, NFS 드라이브가 올바르게 설정된 것을 의미합니다.


