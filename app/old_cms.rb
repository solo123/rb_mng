require 'debug'
module Ns
  module Route
    class App < Roda
      hash_branch("cms") do |r|
        page_size = r.params["page_size"] || 100
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
            Ns::Merchant.where(parent_id: r.params['merchant_id']).and(status: 5)
              .and(:doc_type.ne => 'Ns::CommMerchant')
              .only(:_id, :business, :created_at, :updated_at, :doc_type, :level_code, :platform_merchant_id, :role_id)
              .limit(page_size).all.to_a
          }
        }

        r.on("bill_summaries"){
          r.post("search_by_platform"){
            pls = get_merchant_by_id(r.params['merchant_id']).sub_platform_ids
            r.halt(200, {}) unless pls && !pls.empty?

            pt = Hash.new{|h,k| h[k]=h.dup.clear}        
            dts = get_date_array(r.params['type'], r.params['month'] || r.params['year'])
            Static::PlatformTrade.where(:platform_id.in => pls, :s_date.in => dts)
              .only(:s_date, :platform_id, :amount)
              .each do |d|
              pt[d.platform_id][d.s_date] = d.amount
            end
            old_format_output(pt, dts)
          }

          r.post("search_by_partner"){
            m = Ns::Merchant.find(r.params['merchant_id'])
            r.halt(200, {}) unless m && m.doc_type != 'Ns::CommMerchant'
            dts = get_date_array(r.params['type'], r.params['month'] || r.params['year'])
            partners = []
            m.next_level.where(doc_type: 'Ns::PartnerMerchant').each do |pn|
              partner = {
                id: pn._id, 
                name: pn.business && pn.business[:short_name], 
                level_code: pn.level_code,
                data: {},
                status: false,
              }
              dts.each {|dt| partner[:data][dt] = 0}
              partners << partner
            end
            pls = Ns::Merchant.find(r.params['merchant_id'])&.sub_platform_ids
            r.halt(200, res) unless pls && !pls.empty?

            pt = Hash.new{|h,k| h[k]=h.dup.clear}
            summary = {}
            dts.each {|dt| summary[dt] = 0}
            Static::PlatformTrade.where(:platform_id.in => pls, :s_date.in => dts)
              .only(:s_date, :platform_id, :amount, :level_code)
              .each do |d|
              
              summary[d.s_date] += d.amount
              partners.each do |pn|
                if d[:level_code]&.starts_with?(pn[:level_code])
                  pn[:data][pn[:s_date]] = d.amount
                  pn[:status] = true
                end
              end
            end
            data = partners.select{|k| k[:status]}
            data = data.map{|d| d.merge(d[:data]).except(:data)}
            {data: data, summary: summary}
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
            Static::PlatformTrade.where(:platform_id.in => pls, :s_date.in => dts)
            .only(:s_date, :platform_id, fld)
            .each do |d|
              pt[d.platform_id][d.s_date] = d[fld]
            end
            old_format_output(pt, dts, r.params['export']=='csv')
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
          date_list.each {|dt| item[dt] = 0}
          d.each do |trade_date, val| 
            item[trade_date] = val
            item_tot += val
            summary[trade_date] += val
          end
          item['merchant_id'] = mid
          item['total'] = item_tot
          mids[mid] = item
        end

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