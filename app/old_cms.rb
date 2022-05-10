require 'csv'
require 'zlib'
module Mng
  module Route
    class App < Roda
      hash_branch("cms") do |r|
        page_size = r.params["page_size"] || 300
        @t = {} unless @t

        r.get('csv', String) { |fn|
          response['Content-Type'] = 'text/csv'
          response['Content-Disposition'] = "attachment; filename=#{fn}"
          response['Pragma'] = 'no-cache'
          stream do |out|
            ['a', 'b', 'c', fn].each{|v| out << v}
          end
        }
        
        r.on("merchants") {
          r.post("next_tenants") {
            #TODO: 加上登录后权限和用户类型，识别可用哪些下级
            ms = Ns::Merchant.where(parent_id: r.params['merchant_id']).and(@t)
              .and(:doc_type.ne => 'Ns::CommMerchant')
              .only(:_id, :business, :created_at, :updated_at, :doc_type, :level_code, :platform_merchant_id, :role_id, :status)
              .limit(page_size).all.as_json
            ms.map{|v| v['_type'] = v.delete('doc_type')}
            ms
          }
        }

        r.on("bill_summaries"){
          @t.merge!(r.params.symbolize_keys)
          r.post("search_by_platform"){
            pls = get_merchant_by_id(r.params['merchant_id']).sub_platform_ids
            r.halt(200, {}) unless pls && !pls.empty?

            pt = Hash.new{|h,k| h[k]=h.dup.clear}
            q = Mng::QueryTrade.new
            cnd = q.translate_query_condition(@t)
            q.platform_static(cnd, pls).each do |d|
              pt[d['_id']['pid']][d['_id']['s_date']] = {amount: d['amount'], cnt: d['cnt'], refund: d['refund'], active_cnt: d['active_cnt']}
            end
            dts = get_date_array(r.params['type'], r.params['month'] || r.params['year'])
            old_format_output(pt, cnd, dts).merge(@debug)
          }
          r.post('export_by_platform'){
            fn = "plt#{Zlib.crc32(@t.to_json)}.csv"
            full_fn = "#{Ns::AppConfig.download_dir}/#{fn}"
            unless File.exist?(full_fn)
              pls = get_merchant_by_id(r.params['merchant_id']).sub_platform_ids
              r.halt(200, {}) unless pls && !pls.empty?

              pt = Hash.new{|h,k| h[k]=h.dup.clear}
              q = Mng::QueryTrade.new
              cnd = q.translate_query_condition(@t)
              q.platform_static(cnd, pls).each do |d|
                pt[d['_id']['pid']][d['_id']['s_date']] = {amount: d['amount'], cnt: d['cnt'], refund: d['refund'], active_cnt: d['active_cnt']}
              end
              dts = get_date_array(r.params['type'], r.params['month'] || r.params['year'])
              data = old_format_output(pt, cnd, dts)

              CSV.open(full_fn, "w", force_quotes: true) do |csv|
                data_2_csv(csv, data[:data])
                sm_2_csv(csv, data[:summary])
              end
            end
            {code: 0, data: "https://ws.service.pooul.com/#{fn}"}
          }

          r.post("search_by_partner"){
            m = get_merchant_by_id(r.params['merchant_id'])
            r.halt(200, {}) unless m && m.doc_type != 'Ns::CommMerchant'
            partners = {}
            m.sub_partners.each do |pn|
              partners[pn.id] = {
                level_code: pn.level_code,
              }
            end
            pls_lv = m.sub_platform_ids_level_code
            r.halt(200, res) unless pls_lv && !pls_lv.empty?
            pls_tb = {}
            pls_lv.each {|mid, lv| pls_tb[mid]=lv}
            pls = pls_lv.pluck(0)

            q = Mng::QueryTrade.new
            cnd = q.translate_query_condition(@t)
            q.platform_static(cnd, pls).each do |d|
              partners.each do |mid, dt|
                lc = pls_tb[d[:_id][:pid]]
                if lc&.starts_with?(dt[:level_code])
                  dt[d[:_id][:s_date]] = {amount: d['amount'], cnt: d['cnt'], refund: d['refund'], active_cnt: d['active_cnt']}
                end
              end
            end
            dts = get_date_array(r.params['type'], r.params['month'] || r.params['year'])
            old_format_output(partners, cnd, dts).merge(@debug)
          }
          r.post("export_by_partner"){
            fn = "partner#{Zlib.crc32(@t.to_json)}.csv"
            full_fn = "#{Ns::AppConfig.download_dir}/#{fn}"
            unless File.exist?(full_fn)
              m = get_merchant_by_id(r.params['merchant_id'])
              r.halt(200, {}) unless m && m.doc_type != 'Ns::CommMerchant'
              partners = {}
              m.sub_partners.each do |pn|
                partners[pn.id] = {
                  level_code: pn.level_code,
                }
              end
              pls_lv = m.sub_platform_ids_level_code
              r.halt(200, res) unless pls_lv && !pls_lv.empty?
              pls_tb = {}
              pls_lv.each {|mid, lv| pls_tb[mid]=lv}
              pls = pls_lv.pluck(0)

              q = Mng::QueryTrade.new
              cnd = q.translate_query_condition(@t)
              q.platform_static(cnd, pls).each do |d|
                partners.each do |mid, dt|
                  lc = pls_tb[d[:_id][:pid]]
                  if lc&.starts_with?(dt[:level_code])
                    dt[d[:_id][:s_date]] = {amount: d['amount'], cnt: d['cnt'], refund: d['refund'], active_cnt: d['active_cnt']}
                  end
                end
              end
              dts = get_date_array(r.params['type'], r.params['month'] || r.params['year'])
              data = old_format_output(partners, cnd, dts)

              CSV.open(full_fn, "w", force_quotes: true) do |csv|
                data_2_csv(csv, data[:data])
                sm_2_csv(csv, data[:summary])
              end
            end
            {code: 0, data: "https://ws.service.pooul.com/#{fn}"}
          }

          r.post('month_summary') {
            pls = get_merchant_by_id(r.params['merchant_id']).sub_platform_ids
            cnd = {
              :match => {
                time_period: 'month',
                s_date: { :$gte => "#{r.params['year']}-01", :$lte => "#{r.params['year']}-12" } },
            }
            h = {}
            q = Mng::QueryTrade.new
            q.summary_static(cnd, pls).each do |s|
              h[s[:_id]] = {
                total_fee: s[:amount],
                shoudan: s[:amount],
                order_count: s[:cnt],
                bijun: s[:cnt] > 0 ? s[:amount] / s[:cnt] : 0,
                total_trade_fee: s[:amount],
              }
            end
            h
          }

          # 404 here
          {code: 404, msg: "bill_summaries[#{r.request_method} #{r.path}] not found"}
        } # end of bill_summaries

        r.on("merchant_summaries"){
          @t.merge!(r.params.symbolize_keys)
          r.post('search_by_platform') {
            pls = get_merchant_by_id(r.params['merchant_id']).sub_platform_ids
            pt = Hash.new{|h,k| h[k]=h.dup.clear}
            q = Mng::QueryTrade.new
            cnd = q.translate_query_condition(@t)
            q.platform_static(cnd, pls).each do |d|
              pt[d['_id']['pid']][d['_id']['s_date']] = {amount: d['amount'], cnt: d['cnt'], refund: d['refund'], active_cnt: d['active_cnt']}
            end
            dts = get_date_array(r.params['type'], r.params['month'] || r.params['year'])
            old_format_output(pt, cnd, dts).merge(@debug)
          }
          r.post('export_by_platform'){
            fn = "mch_plt#{Zlib.crc32(@t.to_json)}.csv"
            full_fn = "#{Ns::AppConfig.download_dir}/#{fn}"
            unless File.exist?(full_fn)
              pls = get_merchant_by_id(r.params['merchant_id']).sub_platform_ids
              pt = Hash.new{|h,k| h[k]=h.dup.clear}
              q = Mng::QueryTrade.new
              cnd = q.translate_query_condition(@t)
              q.platform_static(cnd, pls).each do |d|
                pt[d['_id']['pid']][d['_id']['s_date']] = {amount: d['amount'], cnt: d['cnt'], refund: d['refund'], active_cnt: d['active_cnt']}
              end
              dts = get_date_array(r.params['type'], r.params['month'] || r.params['year'])
              data = old_format_output(pt, cnd, dts)

              CSV.open(full_fn, "w", force_quotes: true) do |csv|
                data_2_csv(csv, data[:data])
                sm_2_csv(csv, data[:summary])
              end
            end
            {code: 0, data: "https://ws.service.pooul.com/#{fn}"}
          }

          {code: 404, msg: "merchant_summaries[#{r.request_method} #{r.path}] not found"}  
        } # end of merchant_summaries

        {code: 404, msg: "cms[#{r.request_method} #{r.path}] not found"}
      end

      def old_format_output(src_data, t, dts)
        data = {}
        summary = {}
        dts.each {|dt| summary[dt] = 0}
        ft = t[:field].is_a?(Array)
        src_data.each do |mid, vs|
          d = {merchant_id: mid, total: 0}
          if ft
            d[:total_amount] = 0
            d[:total_cnt] = 0
          end
          data[mid] = d
          dts.each do |dt|
            d[dt] = 0
            if vs.include?(dt)
              v = vs[dt]
              if ft
                m, c = t[:field]
                d[dt] = v[c] > 0 ? v[m] / v[c] : 0
                d[:total_amount] += v[m]
                d[:total_cnt] += v[c]
                d[:total] = d[:total_cnt] > 0 ?  d[:total_amount] / d[:total_cnt] : 0
                if summary[dt].is_a?(Array)
                  summary[dt][0] += v[m]
                  summary[dt][1] += v[c]
                else
                  summary[dt] = [v[m], v[c]]
                end
              else
                #puts "type: #{t[:field].is_a?(Array)}"
                m = v[t[:field]].to_i
                d[dt] = m
                d[:total] += m
                summary[dt] += m
              end
            end
          end
        end
        dts.each do |dt|
          if summary[dt].is_a?(Array)
            m, c = summary[dt]
            summary[dt] = c > 0 ?  m / c : 0
          end
        end

        data.reject!{|_,v| v[:total] == 0}
        Ns::Merchant.where(:_id.in => data.keys).each do |m|
          data[m.id]['name'] = m.short_name
        end
        {data: data.values, summary: summary}
      end

      def data_2_csv(csv, data)
        keys = [:merchant_id, 'name', :total] + data.first.except(:merchant_id, 'name', :total).keys
        csv << keys
        data&.each do |d|
          csv << keys.map{|k| d[k]}
        end
      end
      def sm_2_csv(csv, sum)
        keys = sum.keys
        csv << []
        csv << ["summary:"]
        csv << keys
        csv << keys.map{|k| sum[k]}
      end
    end
  end
end