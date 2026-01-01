const express = require('express');
const { registerUser, loginUser, resetPassword } = require('../controllers/auth/auth');
const {updateProfile, getProfile} = require('../controllers/profile');
const {otpSend, otpVerify} = require('../controllers/otpController');
const {createHomeStats, getHomeStats, updateHomeStats, createHomeStatsPerhari, getKaloriHistory, getLangkahHistory, getJarakHistory, getDurasiHistory, getBeratBadanHistory, saveBeratBadan, updateBeratBadan} = require('../controllers/homeStatsController');
// const {createPetaRute, getPetaRute, updatePetaRute, getIdRute} = require('../controllers/petaRute');
const {createRencanaOlahraga, getRencanaOlahraga, updateRencanaOlahraga, deleteRencanaOlahraga} = require('../controllers/rencanaOlahraga');
const {createOlahraga, getOlahragaByUser, getDetailOlahraga, updateOlahraga} = require('../controllers/olahraga');
const router = express.Router();

router.post('/register', registerUser);
router.post('/login', loginUser);
router.post('/reset-password', resetPassword);

router.post('/profile', updateProfile);
router.get('/profil/:id_pengguna', getProfile);

router.post('/send-otp', otpSend);
router.post('/verify-otp', otpVerify);

router.post('/create-home', createHomeStats);
router.post('/create-home-day', createHomeStatsPerhari);
router.get('/home/:id_pengguna', getHomeStats);
router.put('/home/:id_pengguna', updateHomeStats);
router.get('/home/kalori/:id_pengguna', getKaloriHistory);
router.get('/home/langkah/:userId', getLangkahHistory);
router.get('/home/jarak/:userId', getJarakHistory);
router.get('/home/durasi/:userId', getDurasiHistory);
router.post('/home/berat/:userId', saveBeratBadan);
router.get('/home/berat/:userId', getBeratBadanHistory);
router.put('/home/berat/:statsId', updateBeratBadan);

// router.post('/peta-rute', createPetaRute);
// router.put('/peta-rute/:rute_id', updatePetaRute);
// router.get('/peta-rute/:rute_id', getPetaRute);
// router.get('/peta-rute-id/:olahraga_id', getIdRute);

router.post('/rencana-olahraga', createRencanaOlahraga);
router.get('/rencana-olahraga/:id_pengguna', getRencanaOlahraga);
router.put('/rencana-olahraga/:id_pengguna', updateRencanaOlahraga);
router.delete('/rencana-olahraga/:rencana_id', deleteRencanaOlahraga);

router.post('/olahraga', createOlahraga);
router.get('/olahraga/:id_pengguna', getOlahragaByUser);
router.get('/olahraga-detail/:olahraga_id', getDetailOlahraga);
router.put('/olahraga/:olahraga_id', updateOlahraga);

module.exports = router;
