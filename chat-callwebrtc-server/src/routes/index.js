const express = require('express')
const router = express.Router()
const user = require('../models/user')
const message = require('../models/message')
const actions = require('../actions/action')
const faker = require('faker')
const db = require('../db')
const port = process.env.PORT;


router.get('/', (req, res) => {
    res.send('Node Server is running at port '+ port+' !!');
})

router.get('/dashboard', (req, res) => {
    res.send('Dashboard')
})
router.get('/getUser',async (req,res)=>{
    const users = await user.find()
    res.json(users)
})
router.get('/getMessage',async (req,res)=>{
    const messages = await message.find()
    res.json(messages)
})

router.post('/adduser', actions.addNew)

router.post('/authenticate', actions.authenticate)

router.get('/getinfo', actions.getinfo)

module.exports = router