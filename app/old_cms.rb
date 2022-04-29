require 'debug'
module Mng
  module Route
    class App < Roda
      hash_branch("cms") do |r|
        page_size = r.params["page_size"] || 100
        @t = {} unless @t
        @t.merge!({field: r.params['field']})
        
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
            ms = Ns::Merchant.where(parent_id: r.params['merchant_id']).and(@t || {})
              .and(:doc_type.ne => 'Ns::CommMerchant')
              .only(:_id, :business, :created_at, :updated_at, :doc_type, :level_code, :platform_merchant_id, :role_id, :status)
              .limit(page_size).all.as_json
            ms.map{|v| v['_type'] = v.delete('doc_type')}
            ms
          }
        }

        r.on("bill_summaries"){
          r.post("search_by_platform"){
            pls = get_merchant_by_id(r.params['merchant_id']).sub_platform_ids
            r.halt(200, {}) unless pls && !pls.empty?

            pt = Hash.new{|h,k| h[k]=h.dup.clear}        
            dts = get_date_array(r.params['type'], r.params['month'] || r.params['year'])
            Static::PlatformTrade.where(:platform_id.in => pls, :s_date.in => dts).each do |d|
              pt[d.platform_id][d.s_date] = d.select_field(@t).to_i
            end
            old_format_output(pt, dts).merge(@debug)
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
            dts = get_date_array(r.params['type'], r.params['month'] || r.params['year'])
            Static::PlatformTrade.where(:platform_id.in => pls, :s_date.in => dts).each do |d|
              partners.each do |mid, dt|
                if d[:level_code]&.starts_with?(dt[:level_code])
                  dt[d.s_date] = d.select_field(@t).to_i
                end
              end
            end
            old_format_output(partners, dts).merge(@debug)
          }

          r.post('month_summary')  {
            pls = get_merchant_by_id(r.params['merchant_id']).sub_platform_ids
            dts = ('01'..'12').map{|m| "#{r.params['year']}-#{m}"}
            h = Hash.new { |h, k| h[k] = Hash.new(0) }
            Static::PlatformTrade.where(:platform_id.in => pls, :s_date.in => dts).each do |s|
              h[s[:s_date]][:total_fee] += s.amount.to_i
              h[s[:s_date]][:shoudan] += s.payment[:amount].to_i if s.payment
              h[s[:s_date]][:order_count] += s.cnt.to_i
              h[s[:s_date]][:bijun] += s.cnt.to_i > 0 ? (s.amount.to_i / s.cnt).round(0).to_i : 0
              h[s[:s_date]][:total_trade_fee] += s.amount.to_i
            end
            h
          }

          # 404 here
          {code: 404, msg: "bill_summaries[#{r.request_method} #{r.path}] not found"}
        } # end of bill_summaries

        r.on("merchant_summaries"){
          r.post('search_by_platform') {
            pls = get_merchant_by_id(r.params['merchant_id']).sub_platform_ids
            dts = get_date_array(r.params['type'], r.params['month'] || r.params['year'])
            fld = static_field(r.params['field'])

            pt = Hash.new{|h,k| h[k]=h.dup.clear}
            Static::PlatformTrade.where(:platform_id.in => pls, :s_date.in => dts).each do |d|
              pt[d.platform_id][d.s_date] = d.select_field(@t).to_i
            end
            old_format_output(pt, dts)
          }

          {code: 404, msg: "merchant_summaries[#{r.request_method} #{r.path}] not found"}  
        } # end of merchant_summaries

        {code: 404, msg: "cms[#{r.request_method} #{r.path}] not found"}
      end

      def static_field(para)
        if para == 'total_count'
          'cnt'
        else
          'amount'
        end
      end

      def old_format_output(src_data, date_list, export_file=false)
        mids = {}
        summary = {}
        date_list.each {|dt| summary[dt] = 0}
        src_data.each do |mid, d|
          item = {}
          item_tot = 0
          date_list.each do |dt| 
            item[dt] = 0
            if d.include?(dt) && d[dt] != 0
              item[dt] = d[dt]
              item_tot += d[dt]
              summary[dt] += d[dt]
            end
          end
          item[:merchant_id] = mid
          item[:total] = item_tot
          mids[mid] = item
        end
        mids.reject!{|k,v| v[:total] == 0}
        Ns::Merchant.where(:_id.in => mids.keys).each do |m|
          mids[m.id]['name'] = m.business&.dig('short_name')
        end
        res = {data: mids.values, summary: summary}
        if export_file
          res[:code] = 'csv'
        else
          res
        end
      end
    end
  end
end