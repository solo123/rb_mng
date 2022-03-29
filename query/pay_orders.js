db.ns_pay_orders.aggregate([
{
    $match: {trade_state: 0, s_date: ISODate("2022-01-01"), settle: {'$ne': 1}}
},
{
    $group : {
        _id : "$doc_type", 
        cnt : {$sum : 1},
        amount: {$sum: "$total_fee"}
    }
}
])

db.ns_pay_orders.find()

db.ns_pay_orders.find({settle: {"$ne": null}, doc_type: 'Ns::PayOrder::Alipay'})

db.ns_pay_orders.find({created_at: {"$lte": ISODate("2022-01-01")}, settle: {'$ne': 0}})
db.ns_pay_orders.find({created_at: {"$lte": "2022-01-02"}}) , "s_date" : null})
db.ns_pay_orders.find({s_date: {'$ne': null}}).update_all(s_date: null)
.count()

