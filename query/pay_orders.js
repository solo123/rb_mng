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

# unmatch orders
db.ns_pay_orders.find({
    s_date: ISODate("2022-01-02"),
    doc_type: 'Ns::PayOrder::Wechat',
    settle: {'$ne': 1}
})

db.ns_pay_orders.find(ObjectId("61d2b9f8fd4eb0095ca516a0"))
db.ns_pay_orders.find({})
.sort({_id:-1})
