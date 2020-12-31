const express= require('express')
const multer=require('multer')
const router = express.Router()
const path= require('path')
const models= require('./model')

const mongoose= require('mongoose');
const model = require('./model');

 
 router.use('/uploads', express.static(__dirname +'/uploads'));
 var storage = multer.diskStorage({
    destination: function (req, file, cb) {
      cb(null, 'uploads')
    },
    filename: function (req, file, cb) {
      cb(null, new Date().toISOString()+file.originalname)
    }
  })
   
  var upload = multer({ storage: storage })
  router.post('/upload', upload.single('myFile'), async(req, res, next) => {
    const file = req.file
    if (!file) {
      const error = new Error('Please upload a file')
      error.httpStatusCode = 400
      return next("hey error")
    }
      
      
      const imagepost= new model({
        image: file.path
      })
      const savedimage= await imagepost.save()
      res.json(savedimage)
    
  })

  router.get('/image',async(req, res)=>{
   const image = await model.find()
   res.json(image)
   
  })
  module.exports = router