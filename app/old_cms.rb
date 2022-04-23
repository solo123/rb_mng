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
              .only(:s_date, :platform_id, :amount,)
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
        }
      end
    end
  end
end