1. 把本目录copy到linux
　　如：/root/dump_tools
2. 把obj目录copy到本目录下
　　如：/root/dump_tools/obj
3. 执行create_symbols.sh
　　如：# ./create_symbols.sh
4. copy dump文件到本目录下
　　如：/root/dump_tools/xxxxxxxx.dmp
5. 执行minidump_stackwalk（单个）
　　如：# ./minidump_stackwalk ./xxxxxxxx.dmp ./symbols/ > xxxxxxxx.txt
5. 执行dump_stack（多个）
    如：# ./dump_stack.sh
6. 查看xxxxxxxx.txt，即可判断crash位置