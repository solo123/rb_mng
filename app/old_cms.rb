
module Ns
  module Route
    class App < Roda
      hash_branch("cms") do |r|
        page_size = r.params['page_size']&.to_i || 100
        cnd = {}
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
          req_js = parse_json r.body.read
          r.post("search_by_platform"){
            res = {data: [], summary: {}}
            # r.halt 500, {code: 500, msg: "my halt"}
            pls = Ns::Merchant.find(r.params['merchant_id'])&.sub_platform_ids
            r.halt(200, res) unless pls && !pls.empty?
            if r.params['type'] == 'day'
              dts = (r.params['month'] + '01').to_date.all_month.map{ |d| d.strftime('%Y-%m-%d') }.uniq
            else
              dts = (r.params['year'] + '0101').to_date.all_year.map{ |d| d.strftime('%Y-%m') }.uniq
            end
            pt = Hash.new{|h,k| 
              v={}
              dts.each {|dt| v[dt] = 0}
              h[k] = v
            }            
            Static::PlatformTrade.where(:platform_id.in => pls, :s_date.in => dts)
              .only(:s_date, :platform_id, :amount)
              .each do |d|
              pt[d.platform_id][d.s_date] = d.amount
            end
            data= []
            summary = {}
            dts.each {|dt| summary[dt] = 0}
            pt.each do |k,v|
              tot = 0
              v.each do |vk,vv| 
                tot += vv
                summary[vk] += vv
              end
              v[:merchant_id] = k
              v[:name] = ''
              v[:total] = tot
              data << v
            end
            {data: data, summary: summary, body: req_js}
          }
          r.post("search_by_partner"){
            res = {data: [], summary: {}}
            # r.halt 500, {code: 500, msg: "my halt"}
            m = Ns::Merchant.find(r.params['merchant_id'])
            r.halt(200, res) unless m&.doc_type != 'Ns::CommMerchant'
            if r.params['type'] == 'day'
              dts = (r.params['month'] + '01').to_date.all_month.map{ |d| d.strftime('%Y-%m-%d') }.uniq
            else
              dts = (r.params['year'] + '0101').to_date.all_year.map{ |d| d.strftime('%Y-%m') }.uniq
            end
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

            pt = Hash.new{|h,k| 
              v={}
              dts.each {|dt| v[dt] = 0}
              h[k] = v
            }
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
            {data: data, summary: summary}
          }
   
          r.post('month_summary')  {
            m = Ns::Merchant.find(r.params['merchant_id'])
            r.halt(200, {code: 201, msg: 'empty'}) unless m
            pls = m.sub_platform_ids
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

        
        
        }


      end
    end
  end
end