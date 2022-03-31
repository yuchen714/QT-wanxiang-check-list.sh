# （shell）3402/THP部署检查脚本

部署环境快速检查
3.0 更新：
 

更新内容
      覆盖更多检测项，除terminal终端LANG检查外，已完全覆盖：v3.4.0.2部署前环境检查
      优化了部分输出格式

目前脚本包含的的检测流程：

        1、检查多余的配置文件
        2、检查JAVA版本及JAVA环境变量
        3、检查系统变量
        4、检查umask
        5、提醒确认系统版本是否与安装包适配
        6、检查硬件参数是否达标
        7、检查/data /usr /var下是否有足够空间
        8、检查Selinux服务状态
        9、检查端口冲突
        10、检查组件冲突
        11、检测无密码sudo权限
        12、检查本地防火墙
        13、检查SSH配置文件
        14、sudoers配置文件
        15、passwd以及group文件的隐藏权限
        16、检查主机名是否符合要求
        17、检查第一个高权ssh用户是否是root
        18、部署/升级后手动检查清单



tip：已经做了全分支测试，内部环境测试未发现问题，静候大家拍砖。
##===================================================================
 
使用方式:
部署前上传到每台服务器后，先通过chmod a+x ./check-list.sh 增加执行权限，然后通过./check-list.sh + Options 执行。然后查看回显或者在同目录下生成的check-list-log.txt文件。
如果不方便每台服务器分别上传，可以先上传到PHP服务器上然后通过” scp ./check-list.sh  其他服务器IP:/tmp “命令分别拷贝到其他服务器上/tmp目录下

Options包括:            

    check_before_3402_install     (用于340/3402版本的角色为万相、蜂巢、大数据的服务端部署前环境检查)
    check_before_THP_install       (用于THP1.0.5部署前环境检查，请在安装THP的主机上执行，万象加装大数据请使用 check_before_3402_install 检查大数据主机环境)（THP&万相复用时可以在万相部署完成后再执行该脚本）
    check_before_upgrade        （用于升级到万相3402/THP1.0.5前进行环境检查）
    check_after_3402_upgrade_chinese       （以下Options记录了部署升级完成后需要进行检查、操作的事项，建议部署/升级结束后逐条检查）
    check_after_3402_upgrade_english       
    check_after_3402_install_chinese      
    check_after_3402_install_english      
    check_after_THP_install_chinese        
    check_after_THP_install_english        



3、如果在执行该脚本时遇到问题、或者遇到了脚本中没有检测的环境变量导致的部署失败，请联系我，谢谢！


4、正常运行时的回显：
脚本参数：
 ![image](https://github.com/yuchen714/QT-wanxiang-check-list.sh/blob/main/images/1.png)

少量人工检查部分：

  ![image](https://github.com/yuchen714/QT-wanxiang-check-list.sh/blob/main/images/2.png)

运行后生成的检查结果文件：
  ![image](https://github.com/yuchen714/QT-wanxiang-check-list.sh/blob/main/images/3.png)




