스팀덱의 데스크탑 모드로 진입하고 시놀로지 guest계정의 `uid`, `gid`와 동일하게 매핑할 새로운 사용자를 생성함





![1](https://user-images.githubusercontent.com/122413511/211694613-fc11aee8-7c80-4a56-bd06-d37731642d43.png)

`Konsole`을 실행하고 아래 명령어를 순서대로 입력함


```sh
sudo pacman -Syu

sudo steamos-readonly disable

sudo pacman-key --init

sudo pacman-key --populate

sudo pacman -Syy nfs-utils

sudo pacman -Syu nano

sudo steamos-readonly enable
```

중간에 설치 여부를 묻는 게 나오면 y를 입력해줌



완료되었으면 아래 명령어를 입력함


```sh
sudo nano /etc/passwd
```


생성한 Username `(예시: deck2)`을 찾은 후 우측의 숫자를 변경해줌


```sh
deck2:x:1000:1000:~~~~~ 을 아래와 같이 수정함

=> deck2:x:1025:100:~~~~
```


사진에는 1024인데 1025가 맞음



![2](https://user-images.githubusercontent.com/122413511/211694644-762d0216-bf3f-433d-a0cc-8360d5e5c80e.png)


```sh
sudo nano /etc/group
```


생성한 Username (예시: deck2)을 찾은 후 우측의 숫자를 변경해줌


```sh
deck2:x:1000: 을 아래와 같이 수정함

=> deck2:x:100:
```




![3](https://user-images.githubusercontent.com/122413511/211694682-e26c8add-ea2d-4f0d-873f-d729ad1d4a22.png)



작업이 완료되면 로그아웃을 한번 진행한 후 다시 데스크탑 모드로 진입 후 다시 Konsole을 실행함



NAS와 로컬의 폴더를 매핑하는데 사용할 폴더를 생성함


```sh
sudo mkdir /run/media/testnfs
```


=> 빨간색은 본인이 원하는 폴더명으로 입력하면 됨





![4](https://user-images.githubusercontent.com/122413511/211694749-2d2acf90-6e31-437f-bfb7-9885a6cf46bd.png)





해당 작업 진행 전 fstab는 백업 해두는걸 권장함


```sh
sudo nano /etc/fstab
```


파일의 마지막 줄에 아래 내용을 입력함


```sh
192.168.0.5:/volume1/testDeckNFS /run/media/testnfs nfs default,nfsvers=4,x-systemd.automount,_netdev,retrans=5 0 0
```


=> ip 및 마운트 영역 정보는 본인 환경에 맞게 입력





![5](https://user-images.githubusercontent.com/122413511/211694751-344cedb5-e6dd-4ac0-8a57-277aa680fbbb.png)



입력 완료 후 F3 버튼 클릭 > 엔터 클릭하여 수정 사항 저장 후 F2 버튼 클릭하여 빠져나옴





마운트 명령어를 입력하여 fstab에서 수정한 사항이 정상적으로 동작하는지 테스트를 진행함


```sh
sudo mount -a
```


정상적으로 마운트가 완료되었다면 Dolphin 파일 뷰어의 Remote 영역에 마운트된 폴더가 표시됨





![6](https://user-images.githubusercontent.com/122413511/211694752-58d74a4e-a36e-438b-a865-dc47bb1524cf.png)



테스트 용으로 아무 파일이나 NFS 드라이브로 옮긴 후 파일의 퍼미션을 확인했을때

Ownership이 아래와 같이 나온다면 성공


```sh
User: deck2

Group: deck2
```






![7](https://user-images.githubusercontent.com/122413511/211694754-208d2126-2f1c-4ea9-829c-d7c05a2e14b2.png)





아래 명령어를 입력하여 서비스를 활성화함


```sh
sudo systemctl enable remote-fs.target
```




![8](https://user-images.githubusercontent.com/122413511/211694756-186cce6a-a7f8-49e2-b9bd-77289c0d84e1.png)
