module Fixture
  module Ns
    class Merchant
      def self.clean_data
        ::Ns::Merchant.delete_all
        puts "-- clean: merchants"
      end

      def self.seed_data
        js = [
          {
            "_id": "1001",
            "business": { "short_name": "根节点01" },
            "created_at": "2019-10-17T02:17:00.858Z",
            "doc_type": "Ns::PooulMerchant",
            "level_code": "001",
            "note": "测试用根节点01",
            "role_id": 5,
            "status": 5,
            "updated_at": "2020-04-23T09:33:48.611Z",
          },
          {
            "_id": "2001",
            "business": { "short_name": "合作伙伴01" },
            "created_at": "2019-10-17T02:17:00.858Z",
            "doc_type": "Ns::PartnerMerchant",
            "level_code": "001001",
            "note": "测试合作伙伴01",
            "parent_id": "1001",
            "role_id": 5,
            "status": 5,
            "updated_at": "2020-04-23T09:33:48.611Z",
          },
          {
            "_id": "2002",
            "business": { "short_name": "合作伙伴02" },
            "created_at": "2019-10-17T02:17:00.858Z",
            "doc_type": "Ns::PartnerMerchant",
            "level_code": "001002",
            "note": "测试合作伙伴02",
            "parent_id": "1001",
            "role_id": 5,
            "status": 5,
            "updated_at": "2020-04-23T09:33:48.611Z",
          },
          {
            "_id": "2003",
            "business": { "short_name": "合作伙伴02-01" },
            "created_at": "2019-10-17T02:17:00.858Z",
            "doc_type": "Ns::PartnerMerchant",
            "level_code": "001002001",
            "note": "测试合作伙伴02-01",
            "parent_id": "2002",
            "role_id": 5,
            "status": 5,
            "updated_at": "2020-04-23T09:33:48.611Z",
          },
          {
            "_id": "3001",
            "business": { "short_name": "平台商户01" },
            "created_at": "2019-10-17T02:17:00.858Z",
            "doc_type": "Ns::PlatformMerchant",
            "level_code": "001001001",
            "note": "测试平台01-01",
            "parent_id": "2001",
            "role_id": 5,
            "status": 5,
            "updated_at": "2020-04-23T09:33:48.611Z",
          },
          {
            "_id": "3002",
            "business": { "short_name": "平台商户02-03" },
            "created_at": "2019-10-17T02:17:00.858Z",
            "doc_type": "Ns::PlatformMerchant",
            "level_code": "001002001001",
            "note": "测试平台02-03",
            "parent_id": "2003",
            "role_id": 5,
            "status": 5,
            "updated_at": "2020-04-23T09:33:48.611Z",
          },
        ]
        js.each do |j|
          m = ::Ns::Merchant.create(j)
          puts "-- seed: merchant ID:#{m.id} #{m.short_name}"
        end
      end
    end
  end
end