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

          r.post("search_by_partner"){
            m = get_merchant_by_id(r.params['merchant_id'])
            r.halt(200, {}) unless m && m.doc_type != 'Ns::CommMerchant'
            partners = {}
            m.sub_partners.each do |pn|
              partners[pn.id] = {
                level_code: pn.level_code,
              }
            end
            pls = get_merchant_by_id(r.params['merchant_id'])&.sub_platform_ids
            r.halt(200, res) unless pls && !pls.empty?

            pt = Hash.new{|h,k| h[k]=h.dup.clear}
            q = Mng::QueryTrade.new
            cnd = q.translate_query_condition(@t)
            q.platform_static(cnd, pls).each do |d|
              partners.each do |mid, dt|
                if d[:level_code]&.starts_with?(dt[:level_code])
                  dt[d.s_date] = {amount: d['amount'], cnt: d['cnt'], refund: d['refund'], active_cnt: d['active_cnt']}
                end
              end
            end
            dts = get_date_array(r.params['type'], r.params['month'] || r.params['year'])
            old_format_output(pt, cnd, dts).merge(@debug)
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

          {code: 404, msg: "merchant_summaries[#{r.request_method} #{r.path}] not found"}  
        } # end of merchant_summaries

        {code: 404, msg: "cms[#{r.request_method} #{r.path}] not found"}
      end

      def old_format_output(src_data, t, dts)
        data = {}
        summary = {}
        dts.each {|dt| summary[dt] = 0}
        src_data.each do |mid, vs|
          d = {merchant_id: mid, total: 0}
          data[mid] = d
          dts.each {|dt| d[dt] = 0}
          vs.each do |dt, v|
            if t[:filed].is_a?(Array)
              m, c = t[:field]
              d[dt] = v[m] / v[c]
              d[:total] += d[dt]  #简单平均没有用
              if summary[dt].is_a?(Array)
                summary[dt][0] += v[m]
                summary[dt][1] += v[c]
              else
                summary[dt] = [v[m], v[c]]
              end
            else
              d[dt] = v[t[:field]]
              d[:total] += v[t[:field]]
              summary[dt] += v[t[:field]]
            end
          end
        end
        dts.each do |dt|
          if summary[dt].is_a?(Array)
            m, c = summary[dt]
            summary[dt] = m / c
          end
        end

        data.reject!{|k,v| v[:total] == 0}
        Ns::Merchant.where(:_id.in => data.keys).each do |m|
          data[m.id]['name'] = m.short_name
        end
        res = {data: data.values, summary: summary}
        if t[:export_file]
          res[:code] = 'csv'
        else
          res
        end
      end

    end
  end
end