#!/bin/bash

# Clash 一键管理脚本 (基于 systemctl)

case "$1" in
    start)
        echo "正在启动 Clash..."
        sudo systemctl start clash
        echo "启动命令已发送，请使用 status 检查运行状态。"
        ;;
    stop)
        echo "正在停止 Clash..."
        sudo systemctl stop clash
        echo "Clash 已停止。"
        ;;
    restart)
        echo "正在重启 Clash..."
        sudo systemctl restart clash
        echo "重启命令已发送。"
        ;;
    status)
        sudo systemctl status clash
        ;;
    enable)
        echo "设置 Clash 开机自启..."
        sudo systemctl enable clash
        ;;
    disable)
        echo "取消 Clash 开机自启..."
        sudo systemctl disable clash
        ;;
    log)
        echo "查看 Clash 实时运行日志 (按 Ctrl+C 退出):"
        sudo journalctl -u clash -f
        ;;
    *)
        echo "用法: $0 {start|stop|restart|status|enable|disable|log}"
        echo "示例: ./manage-clash.sh start"
        exit 1
        ;;
esac
