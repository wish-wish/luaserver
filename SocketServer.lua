
--lua socket 测试服务端
--[[
--5 pattern:https://blog.csdn.net/heyan1853/article/details/6457362
            https://www.pianshen.com/article/9965972889/
--select/iocp(Windows):https://blog.csdn.net/zhanghefu/article/details/4420832
--select/poll/epoll(Linux):http://www.cnblogs.com/Anker/p/3265058.html
--select/kqueue/rtsig(real time signals)(BSD/Unix/Osx):https://blog.csdn.net/zdy0_2004/article/details/51805744
--eventport(the effective method--Solaris 10/HP/UX/IRIX/Tru64)
--select和poll是一个级别的，epoll和kqueue是一个级别的
--reactor：反应器，能收了你跟俺说一声，我去收。proactor: 代理人，你给我收十个字节，收好了跟俺说一声，我去读。
--java nio:windows用的是select
--]]

package.path=package.path..";;./?.lua;D:/Program Files (x86)/Lua/5.1/lua/?.lua;D:/Program Files (x86)/Lua/5.1/lua/?/init.lua;D:/Program Files (x86)/Lua/5.1/?.lua;"
package.path=package.path.."D:/Program Files (x86)/Lua/5.1/?/init.lua;D:/Program Files (x86)/Lua/5.1/lua/?.luac;lua/lua/?.lua;?.lua;?.luac;luac/*.luac"
package.cpath=package.cpath..";;./?.dll;D:/Program Files (x86)/Lua/5.1/?.dll;D:/Program Files (x86)/Lua/5.1/loadall.dll;D:/Program Files (x86)/Lua/5.1/clibs/?.dll;"
package.cpath=package.cpath..";D:/Program Files (x86)/Lua/5.1/clibs/loadall.dll;./?51.dll;D:/Program Files (x86)/Lua/5.1/?51.dll;D:/Program Files (x86)/Lua/5.1/clibs/?51.dll;lua/lib/*.lua";
print('path='..package.path)
print('cpath='..package.cpath)

local SocketServer = {}

function SocketServer:ctor()

end

function SocketServer:dispose()

end

function SocketServer:startServer()
    local socket=require("socket")
    local host="127.0.0.1"
    local port=12345;
    local server=socket.bind(host,port,1024);
    server:settimeout(0);
    local client_tab={};
    local conn_count = 0;
    print("Server Start %s:%d",host,port);
    while true do
        local conn=server:accept();
        if conn then
            conn_count=conn_count+1;
            client_tab[conn_count]=conn;
            print("A client successfully connect!"..conn_count);
            conn:send("connect ok\n");
        end
        local del_tab={};
        for cindex,client in pairs(client_tab) do--broadcast
            local recvt,sendt,status = socket.select({client},nil,1);
            if #recvt>0 then
                local receiver,receive_status=client:receive();
                if receive_status~="closed" then
                    if receiver then
                        print("Receive Client "..cindex..":"..receiver);
                        client:send("client "..cindex.." Send");
                        client:send(receiver.." Send");
                    end
                else                    
                    del_tab[cindex]=client;
                end
            end
        end
        for cindex,client in pairs(del_tab) do--clear dead client
            table.remove(client_tab,cindex);
            client:close();
            print("client "..cindex.. "disconnect");
        end
    end
end

SocketServer:startServer();

return SocketServer
