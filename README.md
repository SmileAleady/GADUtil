# GADUtil

该工程只具有插屏和原生两种广告位复用，若需添加新的广告位请联系 1348705840@qq.com 也欢迎多多交流

#⚠️注意事项：

1. 需在主工程中导入GADMobile.json文件

2. 文件格式如下

{
    "showTimes":30,
    "clickTimes":5,
    "ads": [
        {
            "key": "interstitial",
            "value": [
                {
                    "theAdPriority":1,
                    "theAdID":"ca-app-pub-3940256099942544/4411468910"
                },
                {
                    "theAdPriority":3,
                    "theAdID":"ca-app-pub-3940256099942544/4411468910X3"
                },
                {
                    "theAdPriority":2,
                    "theAdID":"ca-app-pub-3940256099942544/5135589807"
                }
            ]
        },
        {
            "key": "native",
            "value": [
                {
                    "theAdPriority":1,
                    "theAdID":"ca-app-pub-3940256099942544/2521693316"
                },
                {
                    "theAdPriority":2,
                    "theAdID":"ca-app-pub-3940256099942544/3986624511"
                },
                {
                    "theAdPriority":3,
                    "theAdID":"ca-app-pub-3940256099942544/3986624511X3"
                }
            ]
        }
    ]
}

3. info.plist文件添加如下字段

    <key>GADApplicationIdentifier</key>
    <string></string>
    <key>GADIsAdManagerApp</key>
    <true/>
