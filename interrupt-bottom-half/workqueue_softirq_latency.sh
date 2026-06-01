#!/bin/bash
# workqueue_softirq_latency.sh
# Work Queue와 Soft IRQ latency를 ftrace로 비교 측정하는 스크립트
# 실습 환경: Raspberry Pi 3A+ / Linux 6.12.x

TRACING=/sys/kernel/debug/tracing

init_trace() {
    echo "=== ftrace 초기화 ==="
    sudo sh -c "echo 0 > $TRACING/tracing_on"
    sudo sh -c "echo > $TRACING/trace"
    sudo sh -c "echo '' > $TRACING/set_event"
}

measure_softirq() {
    echo ""
    echo "=== [1] Soft IRQ latency 측정 (5초) ==="
    sudo sh -c "echo 'irq:softirq_raise irq:softirq_entry irq:softirq_exit' > $TRACING/set_event"
    sudo sh -c "echo 1 > $TRACING/tracing_on"
    sleep 5
    sudo sh -c "echo 0 > $TRACING/tracing_on"

    echo ""
    echo "--- NET_RX Soft IRQ 결과 ---"
    sudo cat $TRACING/trace | grep NET_RX | head -20

    sudo sh -c "echo > $TRACING/trace"
}

measure_workqueue() {
    echo ""
    echo "=== [2] Work Queue latency 측정 (5초) ==="
    sudo sh -c "echo 'workqueue:workqueue_queue_work workqueue:workqueue_execute_start workqueue:workqueue_execute_end' > $TRACING/set_event"
    sudo sh -c "echo 1 > $TRACING/tracing_on"
    sleep 5
    sudo sh -c "echo 0 > $TRACING/tracing_on"

    echo ""
    echo "--- brcmf Work Queue 결과 ---"
    sudo cat $TRACING/trace | grep brcmf | head -20

    sudo sh -c "echo > $TRACING/trace"
}

cleanup() {
    echo ""
    echo "=== 정리 ==="
    sudo sh -c "echo 0 > $TRACING/tracing_on"
    sudo sh -c "echo > $TRACING/trace"
    sudo sh -c "echo '' > $TRACING/set_event"
    echo "완료"
}

# 실행
init_trace
measure_softirq
measure_workqueue
cleanup
