# AD client
```
* 해당 adclient.sh 코드는 하모니카 OS 에서 AD Connection 설정 및 연결을 도와주는 Client script 입니다.
* 해당 소스코드는 pbis-open 을 사용합니다. (https://repo.pbis.beyondtrust.com/apt.html)
```

# TODO
```
* 브랜치 생성 완료
* 내부에서 개발 후 깃에 반영 예정
```

### How to use...
```
* 1. git clone https://github.com/hamonikr/hamonikr-ldapconn.git
* 2. cd hamonikr-ldapconn
* 3. sudo sh ./adconnect.sh
```

### AD Client confige setting 
```
sudo /opt/pbis/bin/config UserDomainPrefix 도메인명
sudo /opt/pbis/bin/config AssumeDefaultDomain true
sudo /opt/pbis/bin/config LoginShellTemplate /bin/bash
sudo /opt/pbis/bin/config HomeDirTemplate 사용자 홈 폴더 위치 ex) %H/%U
sudo /opt/pbis/bin/config RequireMembershipOf 도메인\\\도메인유저 ex) domain\\\Domain^Users
sudo /opt/pbis/bin/ad-cache --delete-all 
sudo /opt/pbis/bin/update-dns 
```

### AD Connection 확인 
```
* sudo domainjoin-cli join query
* sudo domainjoin-cli join leave 
```
