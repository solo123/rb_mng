module Ns
  module Lib
    class NginxLog
      REG_NGINX = [
        /^\[(?<datetime>[^\]]+)\] (?<ip>[0-9\.]+) => (?<request_url>\S+) \[(?<status>\d+)\] \(\)$/,
        /^(?<method>\S+) (?<path>\S+) HTTP\/(?<http_ver>\S+) \((?<length>[^\)]+)\) time_elapsed: (?<time_elapsed>\S+)$/,
        /Accept\-Encoding\: (?<encoding>[^|]+)\| Content\-Type\: (?<content_type>\S+)$/,
        /^User-Agent: (?<user_agent>[\S ]*)$/,
      ]
      VS_PATTEN = /^Byte: (?<length>\d+) ratio: (?<ratio>\S+)/
      MAX_LINES = 10

      def initialize(log_filename)
        @log_filename = log_filename
        @lines = []
        @line_cnt = 0
        @f_cnt = 0
      end

      def parse
        IO.foreach(@log_filename) do |line|
          l = line.chomp
          if l.empty?
            break unless parse_block()
          else
            @lines << l
          end
        end
        parse_block
        puts "--Done #{@line_cnt} lines--"
      end

      def parse_block
        return true if @lines.empty?

        ms = {}
        @lines.each_with_index do |line, i|
          m = line.match(REG_NGINX[i])
          unless m
            puts "Error: --"
            puts line
            puts "reg: #{REG_NGINX[i].to_s}\n"
            puts 'source:'
            puts @lines
            break
          end
          ms.merge!(m.named_captures)
        end
        unless ms.empty?
          if ms['path']
            ms['path_res'], ms['url_params'] = ms['path'].split('?')
            if ms['path_res'] && !ms['path_res'].empty?
              _, ms['path1'], ms['path2'], ms['path3'] = ms['path_res'].split('/')
            end
          end
          if ms['length']
            m = ms['length'].match(VS_PATTEN)
            if m
              ms.merge!(m.named_captures)
            end
          end
          if ms['status']
            ms['status'] = ms['status'].to_i
          end
          if ms['time_elapsed']
            ms['time_elapsed'] = ms['time_elapsed'].to_f
          end
          if ms['length']
            ms['length'] = ms['length'].to_i
          end
          if ms['ratio']
            ms['ratio'] = ms['ratio'].to_f
          end
          puts ms.inspect
        end
        @lines.clear()
        @line_cnt += 1
        return MAX_LINES > @line_cnt
      end
    end
  end
end
