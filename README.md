# clash for linux 一键使用

1. 切换到clash文件夹
`cd clash`
2. 将配置文件放在 clash文件夹下
`config.yaml`
3. 运行clash
`./clash -d .`
6. 设置系统代理
`export http_proxy=http://127.0.0.1:7890 https_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890`
7. 测试是否连上
`curl -I www.google.com`

   
```./clash -h
Usage of ./clash:
  -d string
        set configuration directory 设置配置目录
  -ext-ctl string
        override external controller address
  -ext-ui string
        override external ui directory
  -f string
        specify configuration file 设置配置文件
  -secret string
        override secret for RESTful API
  -t    test configuration and exit
  -v    show current version of clash
```