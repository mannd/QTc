//
//  QTc_iOSTests.swift
//  QTc_iOSTests
//
//  Created by David Mann on 9/2/17.
//  Copyright © 2017, 2018 EP Studios. All rights reserved.
//

import XCTest
@testable import QTc

class QTc_iOSTests: XCTestCase {
    // Add formulas to these arrays as they are created
    let qtcFormulas: [Formula] = [.qtcBzt, .qtcArr, .qtcDmt, .qtcFrd, .qtcFrm, .qtcHdg, .qtcKwt, .qtcMyd, .qtcYos]
    let qtpFormulas: [Formula] = [.qtpArr]
    // Accuracy for all non-integral measurements
    let delta = 0.0000001
    let roughDelta = 0.1
    let veryRoughDelta = 0.5  // accurate to nearest half integer
    let veryVeryRoughDelta = 1.0 // accurate to 1 integer
    // source: https://link.springer.com/content/pdf/bfm%3A978-3-642-58810-5%2F1.pdf
    // Note this table is not accurate within 0.5 bpm when converting back from interval to rate
    let rateIntervalTable: [(rate: Double, interval: Double)] = [(20, 3000),  (25, 2400),
                                                                 (30, 2000), (35, 1714), (40, 1500),
                                                                 (45, 1333), (50, 1200), (55, 1091),
                                                                 (60, 1000), (65, 923), (70, 857), (75, 800),
                                                                 (80, 750), (85, 706), (90, 667), (95, 632),
                                                                 (100, 600), (105, 571), (110, 545), (115, 522),
                                                                 (120, 500), (125, 480), (130, 462), (135, 444),
                                                                 (140, 429), (145, 414), (150, 400), (155, 387),
                                                                 (160, 375), (165, 364), (170, 353), (175, 343),
                                                                 (180, 333), (185, 324), (190, 316), (195, 308),
                                                                 (200, 300), (205, 293), (210, 286), (215, 279),
                                                                 (220, 273), (225, 267), (230, 261), (235, 255),
                                                                 (240, 250), (245, 245), (250, 240), (255, 235),
                                                                 (260, 231), (265, 226), (270, 222), (275, 218),
                                                                 (280, 214), (285, 211), (290, 207), (295, 203),
                                                                 (300, 200), (305, 197), (310, 194), (315, 190),
                                                                 (320, 188), (325, 185), (330, 182), (335, 179),
                                                                 (340, 176), (345, 174), (350, 171), (355, 169),
                                                                 (360, 167), (365, 164), (370, 162), (375, 160),
                                                                 (380, 158), (385, 156), (390, 154), (395, 152),
                                                                 (400, 150)]
    // uses online QTc calculator: http://www.medcalc.com/qtc.html, random values
    let qtcBztTable: [(qt: Double, interval: Double, qtc: Double)] = [(318, 1345, 274), (451, 878, 481), (333, 451, 496)]
    // TODO: Add other hand calculated tables for each formula
    // table of calculated QTc from
    let qtcMultipleTable: [(rate: Double, rrInSec: Double, rrInMsec: Double, qtInMsec: Double,
        qtcBzt: Double, qtcFrd: Double, qtcFrm: Double, qtcHDG: Double)] =
        [(88, 0.682, 681.8, 278, 336.7, 315.9, 327.0, 327.0), (112, 0.536, 535.7, 334, 456.3, 411.2, 405.5, 425.0),
         (47, 1.2766, 1276.6, 402, 355.8, 370.6, 359.4, 379.3), (132, 0.4545, 454.5, 219, 324.8, 284.8, 303, 345)]
    
    // TODO: Add new formulae here
    let qtcRandomTable: [(qtInSec: Double, rrInSec: Double, qtcMyd: Double, qtcRtha: Double,
        qtcArr: Double, qtcKwt: Double, qtcDmt: Double)] = [(0.217, 1.228, 0.191683142324075,
                                                             0.20357003257329, 0.188180853891965, 0.206138989195107, 0.199352096980993),
                                                            (0.617, 1.873, 0.422349852160997, 0.521139348638548,
                                                             0.540226253226725,0.527412865616186 , 0.476131661614717),
                                                            (0.441, 0.024, 4.19557027148694, 6.419, 0.744999998985912,
                                                             1.12043270968093, 2.05783877711859),
                                                            (0.626, 1.938, 0.419771215123981, 0.525004471964224,
                                                             0.545939267391605, 0.530561692609049, 0.47631825370458),
                                                            (0.594, 1.693, 0.432192914133319, 0.512952155936208,
                                                             0.527461134835087, 0.520741518839723, 0.477915505801712),
                                                            (0.522, 0.670, 0.664846401046771, 0.607701492537313,
                                                             0.585658505426308, 0.576968100296572, 0.615887811579245),
                                                            (0.162, 0.238, 0.385533865286431, 0.334890756302521,
                                                             0.400524764066341, 0.231937395103792, 0.29308171977912),
                                                            (0.449, 0.738, 0.539436462235939, 0.50213369467028,
                                                             0.496257865770434, 0.484431360905827, 0.509024942553452),
                                                            (0.364, 0.720, 0.443887132523326, 0.411185185185185,
                                                             0.415398777435965, 0.395155707875796, 0.416891521344714),
                                                            (0.279, 0.013, 3.84399149834848, 7.33984615384616,
                                                             0.583, 0.826263113547243, 1.67704840828666),
                                                            (0.184, 0.384, 0.328005981451736, 0.282388888888889,
                                                             0.347039639944786, 0.233741064151123, 0.27320524164178)]

    // QTp random test intervals
    let qtIntervals =
[0.587, 0.628, 0.774, 0.44, 0.61, 0.564, 0.322, 0.652, 0.611, 0.771, 0.522, 0.282, 0.255, 0.542, 0.4, 0.706, 0.301, 0.389, 0.486, 0.499]
    let rrIntervals = 
[1.04, 1.741, 0.803, 0.744, 0.462, 1.741, 0.814, 1.492, 1.217, 1.316, 1.072, 1.729, 1.631, 0.876, 0.738, 1.325, 1.066, 0.57, 0.603, 0.821]
    let qtpBztMaleResults =
[0.377327444005866, 0.488203748449354, 0.331557988894854, 0.319145108062148, 0.251491152925903, 0.488203748449354, 0.333821209631743, 0.451945571944233, 0.40817557496744, 0.42445305983112, 0.383088501524126, 0.486518344977864, 0.472529258353385, 0.346301025121209, 0.317855627604735, 0.425901984029189, 0.382014921174553, 0.279343874105018, 0.287316376143094, 0.335253486186199]
    let qtpBztFemaleResults = [0.407921561087423, 0.527787836161464, 0.358441069075518, 0.345021738445565, 0.271882327487463, 0.527787836161464, 0.360887794196479, 0.488589807507279, 0.441270891856692, 0.4588681727904, 0.414149731377433, 0.525965778354448, 0.510842441463119, 0.374379486617523, 0.343627705518633, 0.460434577328854, 0.41298910397249, 0.30199337741083, 0.310612298533075, 0.362436201282377]
    let qtpFrdResults =
[0.386559422661292, 0.458991603861966, 0.354631247099717, 0.345723947150657, 0.294952767914911, 0.458991603861966, 0.356243229467337, 0.435974838280842, 0.407350896973457, 0.41810989654274, 0.390484152137325, 0.457934624637034, 0.449113873741475, 0.365067512187644, 0.344792072153498, 0.41906087001553, 0.389754273515837, 0.316346792990953, 0.322337565550937, 0.357261488417636]
    let qtpHdgResults = [0.395038461538462, 0.435689833429064, 0.365240348692403, 0.354870967741935, 0.268727272727273, 0.435689833429064, 0.367007371007371, 0.425624664879357, 0.409722267871816, 0.416212765957447, 0.39805223880597, 0.435271255060729, 0.431622317596566, 0.37613698630137, 0.353723577235772, 0.416754716981132, 0.397500938086304, 0.311789473684211, 0.321870646766169, 0.3681071863581]
    let qtcRthbMaleResults = [0.581343039402066, 0.539876501292278, 0.804174636591087, 0.480109064822965, 0.706177170185111, 0.475876501292278, 0.35037381620353, 0.59024899978608, 0.581832195881668, 0.729613630344318, 0.511915407946455, 0.195090829692423, 0.178212616137001, 0.560500006698053, 0.441146783627781, 0.663531970103914, 0.291739182875841, 0.46167084747726, 0.55205665809079, 0.526235809548196]
    let qtcRthbFemaleResults = [0.580695812286438, 0.52926765756804, 0.807541128337159, 0.484551008433048, 0.716354877945081, 0.465267657568039, 0.353543571822623, 0.582928175464681, 0.57844314285625, 0.724767662325179, 0.510758174544893, 0.184635377981728, 0.169028318291773, 0.562581497625133, 0.44570009096784, 0.658556002180993, 0.29067706412139, 0.469515787318061, 0.559226003573487, 0.529280960371902]
    let qtpMydResults = [0.425497173513281, 0.580832622192216, 0.363962577477372, 0.347567048264256, 0.260646739027945, 0.580832622192216, 0.366965877563262, 0.529133078075342, 0.467868764175226, 0.490500099361997, 0.433357376010936, 0.578411232930745, 0.558381132281235, 0.383602141228905, 0.345871346870654, 0.49252347281055, 0.43189074158302, 0.29590816947795, 0.30614008546182, 0.368868703669459]
    // QTpKRJ is rate dependent
    let qtpKrjSlowResults = [0.39764, 0.478956, 0.370148, 0.363304, 0.330592, 0.478956, 0.371424, 0.450072, 0.418172, 0.429656, 0.401352, 0.477564, 0.466196, 0.378616, 0.362608, 0.4307, 0.400656, 0.34312, 0.346948, 0.372236]
    let qtpKrjFastResults = [0.49836, 0.767544, 0.407352, 0.384696, 0.276408, 0.767544, 0.411576, 0.671928, 0.566328, 0.604344, 0.510648, 0.762936, 0.725304, 0.435384, 0.382392, 0.6078, 0.508344, 0.31788, 0.330552, 0.414264]
    let qtpKrjMediumResults = [0.39824, 0.507596, 0.361268, 0.352064, 0.308072, 0.507596, 0.362984, 0.468752, 0.425852, 0.441296, 0.403232, 0.505724, 0.490436, 0.372656, 0.351128, 0.4427, 0.402296, 0.32492, 0.330068, 0.364076]
    let qtpSchResults =  [0.3802, 0.523905, 0.331615, 0.31952, 0.26171, 0.523905, 0.33387, 0.47286, 0.416485, 0.43678, 0.38676, 0.521445, 0.501355, 0.34658, 0.31829, 0.438625, 0.38553, 0.28385, 0.290615, 0.335305]
    let qtpAdmMenResults = [0.405944, 0.5136176, 0.3695408, 0.3604784, 0.3171632, 0.5136176, 0.3712304, 0.4753712, 0.4331312, 0.4483376, 0.4108592, 0.5117744, 0.4967216, 0.3807536, 0.3595568, 0.44972, 0.4099376, 0.333752, 0.3388208, 0.3723056]
    let qtpAdmWomenResults = [0.409836, 0.4980919, 0.3799977, 0.3725696, 0.3370658, 0.4980919, 0.3813826, 0.4667428, 0.4321203, 0.4445844, 0.4138648, 0.4965811, 0.4842429, 0.3891884, 0.3718142, 0.4457175, 0.4131094, 0.350663, 0.3548177, 0.3822639]
    let qtpAdmCombinedResults = [0.409456, 0.5120824, 0.3747592, 0.3661216, 0.3248368, 0.5120824, 0.3763696, 0.4756288, 0.4353688, 0.4498624, 0.4141408, 0.5103256, 0.4959784, 0.3854464, 0.3652432, 0.45118, 0.4132624, 0.340648, 0.3454792, 0.3773944]
    let ages = [45, 43, 36, 49, 32, 57, 23, 45, 26, 31, 54, 45, 50, 49, 29, 26, 42, 47, 36, 42]
    let qtpSmnResults = [0.4014, 0.49894, 0.36552, 0.36116, 0.31658, 0.50314, 0.36316, 0.46468, 0.42048, 0.43584, 0.40858, 0.49786, 0.48564, 0.37964, 0.35432, 0.4356, 0.40414, 0.3362, 0.33752, 0.36984]
    let qtpKwtResults = [0.454434032947036, 0.516906753734889, 0.425982148944625, 0.417932117799132, 0.370999229501259, 0.516906753734889, 0.427433557189848, 0.497341522548198, 0.472645098358642, 0.481977190824566, 0.457890053953813, 0.516013735565187, 0.508541036683082, 0.43534999150123, 0.417086952467717, 0.482799135016553, 0.457248000417796, 0.391004024677794, 0.396544418864229, 0.428349538226906]
    let qtpScl20to40Results = [0.3738622153476, 0.443915237311756, 0.342982775479653, 0.334368051076366, 0.285264538311867, 0.443915237311756, 0.34454180952133, 0.421654496877457, 0.393970758021775, 0.404376359794986, 0.377658030351792, 0.442892976382533, 0.434361958180625, 0.353076243539145, 0.33346678511196, 0.405296096912831, 0.376952125845609, 0.305955839936506, 0.311749835295614, 0.345526622009758]
    let qtpScl40to60Results = [0.377154083910409, 0.447823924935884, 0.346002749603373, 0.337312172280812, 0.287776301542286, 0.447823924935884, 0.347575510988814, 0.425367177982039, 0.397439682935174, 0.407936906359218, 0.380983321185079, 0.446792662967033, 0.438186528881586, 0.356185090966534, 0.336402970641248, 0.408864741791309, 0.38027120116752, 0.3086497907284, 0.314494802398846, 0.348568994782171]
    let qtpScl60to70Results = [0.383267554098483, 0.455082916237838, 0.351611272975997, 0.342779825946212, 0.292441004684493, 0.455082916237838, 0.353209527999854, 0.432262157176261, 0.403881972060058, 0.414549349978507, 0.387158861304039, 0.454034938052534, 0.445289303040515, 0.361958664760256, 0.341855886624211, 0.415492225137053, 0.386435198193926, 0.31365284219906, 0.319592598447705, 0.354219115645224]
    let qtpSclOver70Results = [0.388440490411469, 0.461225139647183, 0.356356946598986, 0.347406302124627, 0.296388061189437, 0.461225139647183, 0.357976773163043, 0.438096370340604, 0.409333139781115, 0.420144494579444, 0.392384318327774, 0.460163016971034, 0.451299342713454, 0.366843996431866, 0.346469892455949, 0.421100095660375, 0.391650887985501, 0.317886193443464, 0.323906118181355, 0.35899998714473]
    let qtpMrrCombinedResults = [0.413821771693228, 0.508533430672105, 0.373152381869917, 0.361933826377932, 0.29912780919351, 0.508533430672105, 0.375188710548383, 0.478087654563197, 0.440672786059032, 0.454676340321416, 0.41886870507502, 0.507128475779878, 0.495429182453337, 0.386368438266048, 0.36076346102693, 0.455917593187799, 0.417929359993219, 0.325349349141896, 0.332756789013529, 0.37647597165676]
    let qtpMrrMaleResults = [0.424125777984843, 0.532048789322944, 0.378507805564762, 0.366009275588722, 0.29678535674638, 0.532048789322944, 0.380780533626931, 0.497116618990778, 0.454493686215864, 0.470405717058715, 0.429819095149359, 0.530432098509776, 0.516987143164534, 0.393279950653825, 0.364707587991336, 0.471818522676574, 0.428758921733536, 0.325525441425888, 0.333687253469035, 0.382217871036895]
    let qtpMrrFemaleResults = [0.43332459094498, 0.532499872895024, 0.390738511829181, 0.37899124210563, 0.313225268522446, 0.532499872895024, 0.392870809721618, 0.500619231563821, 0.461441054631539, 0.47610457607386, 0.438609378969167, 0.531028704518649, 0.518778040484407, 0.404577421774221, 0.377765719134946, 0.4774043273856, 0.437625763917541, 0.340682591576259, 0.348439133333816, 0.394218737576994]
    let qtcYosResults = [0.579906218804505, 0.528825056770059, 0.828474492438624, 0.48224203851013, 0.774980584992121, 0.474932057354002, 0.343211875252954, 0.575942676843373, 0.574911678752592, 0.70808444229737, 0.510869669852896, 0.237975725997005, 0.219118704977358, 0.564706795107062, 0.439503683395084, 0.647020109439033, 0.295094939615308, 0.463050541134329, 0.568509730648057, 0.530461863859337]
    let qtpHggResults = [0.397723522060237, 0.514593140257427, 0.34948004234863, 0.336396194984426, 0.265085269300276, 0.514593140257427, 0.351865599341567, 0.476375062319597, 0.430239119560274, 0.44739646847064, 0.403795988092997, 0.512816633895587, 0.498071380426541, 0.365019999452085, 0.335037012880667, 0.448923712895632, 0.402664376373178, 0.294443542975559, 0.302846991069748, 0.353375296250318]
    let qtcGotResults = [0.579203844535374, 0.519841973412787, 0.834110198571954, 0.486668752869248, 0.793694526906362, 0.466864447459891, 0.345401335203816, 0.568865772485733, 0.571433440838143, 0.702101733629883, 0.509773318369705, 0.233983264079855, 0.215831398660427, 0.567021643889854, 0.443649072162604, 0.641418243478878, 0.294512725299276, 0.471163742780999, 0.577465572639112, 0.533704621330601]
    let qtpGotResults = [0.44085515386182, 0.525505853647332, 0.403651700430511, 0.393285985326909, 0.334322577521446, 0.525505853647332, 0.405528252857931, 0.498571040336432, 0.465119786497204, 0.477687183972686, 0.445433277532429, 0.524268265435149, 0.513942830785809, 0.41580423347261, 0.392201879633879, 0.478798355242157, 0.444581808364807, 0.359142660259095, 0.366099746923131, 0.406713735134663]
    let qtpKlgResults = [0.404846153846154, 0.435508902929351, 0.382369863013699, 0.374548387096774, 0.309571428571429, 0.435508902929351, 0.383702702702703, 0.427916890080429, 0.415921939194741, 0.420817629179331, 0.407119402985075, 0.435193175245807, 0.432440833844267, 0.39058904109589, 0.373682926829268, 0.42122641509434, 0.406703564727955, 0.342052631578947, 0.34965671641791, 0.38453227771011]
    let qtpShpMaleResults = [0.404862149379267, 0.523829427390253, 0.355752761057451, 0.342434075407223, 0.269843210031307, 0.523829427390253, 0.358181135740005, 0.484925383950975, 0.437961360167766, 0.455426661494472, 0.411043608392102, 0.522021035016789, 0.507011123152145, 0.371571640467891, 0.341050497727243, 0.456981317998887, 0.409891685692696, 0.299728427080249, 0.308282706294077, 0.35971792977276]
    let qtpShpFemaleResults = [0.423218619628201, 0.547579880017518, 0.37188260916585, 0.357960053637274, 0.282077914768243, 0.547579880017518, 0.374421086478847, 0.506911925288802, 0.457818550301318, 0.47607572927004, 0.429680346304087, 0.545689495042739, 0.529999033017986, 0.38841871736568, 0.356513744475581, 0.477700873978685, 0.428476195371458, 0.313318129063736, 0.322260259728065, 0.376027558830467]
    let qtpWhlResults = [0.388038461538462, 0.416610568638713, 0.367094645080946, 0.359806451612903, 0.29925974025974, 0.416610568638713, 0.368336609336609, 0.409536193029491, 0.398359079704191, 0.402920972644377, 0.39015671641791, 0.416316367842684, 0.413751686082158, 0.374753424657534, 0.359, 0.403301886792453, 0.389769230769231, 0.329526315789474, 0.336611940298507, 0.369109622411693]
    let qtpAshChildrenResults = [0.391996117044997, 0.471719418867772, 0.352880341389589, 0.34148415183345, 0.272216862110643, 0.471719418867772, 0.354919599379902, 0.447630386077981, 0.416091955089145, 0.428161211353421, 0.396624788966186, 0.470636686254582, 0.461514117604713, 0.365959176150672, 0.34027926029047, 0.429215327853606, 0.395766874265625, 0.302317490243958, 0.310505649083991, 0.356204139013828]
    let qtpAshWomen40Results = [0.405585315769223, 0.488072358721855, 0.365113526557761, 0.35332226909701, 0.281653713330479, 0.488072358721855, 0.367223478825072, 0.463148239462017, 0.430516476198902, 0.443004133347006, 0.410374448317014, 0.486952091378074, 0.477513273681677, 0.378645760923896, 0.352075607980539, 0.444094792552531, 0.4094867925735, 0.312797829905748, 0.321269844918903, 0.368552549166307]
    let qtpAshOldMenResults = [0.39722273193893, 0.478009011119342, 0.357585412608116, 0.346037273857897, 0.275846420272118, 0.478009011119342, 0.359651860704968, 0.453598791225687, 0.421639847823667, 0.433870027504799, 0.401913119485735, 0.476911842071309, 0.467667639172776, 0.370838631832681, 0.344816317094343, 0.434938198891654, 0.4010437659225, 0.306348390113877, 0.314645724405111, 0.360953527534012]
    let qtpAshOldWomenResults = [0.407675961726796, 0.490588195622483, 0.366995555045172, 0.355143517906788, 0.283105536595069, 0.490588195622483, 0.369116383355099, 0.4655356015211, 0.432735633292711, 0.445287659807557, 0.412489780524833, 0.489462153704765, 0.479974682308902, 0.380597543196699, 0.353890430702089, 0.44638394096775, 0.41159754923625, 0.314410189853716, 0.322925875047351, 0.370452304574381]
    let qtpSrmResults = [0.467943852816009, 0.501964962009996, 0.432041878958843, 0.418924693761001, 0.317265549437452, 0.501964962009996, 0.434264663415656, 0.496178946347809, 0.483161815926127, 0.488987775833421, 0.471259409594866, 0.501766224618623, 0.499877953540303, 0.445630139774855, 0.417469921964094, 0.489444204809106, 0.470659364790308, 0.365508528402883, 0.377655343054707, 0.435645174354612]
    let qtpLccResults = [0.410586099174599, 0.423922662115945, 0.390357090382849, 0.381905599234239, 0.302661343013188, 0.423922662115945, 0.391738749324714, 0.422293129755823, 0.417512064869254, 0.41980865364909, 0.412195546039764, 0.423873750511202, 0.423381510873599, 0.39855695761056, 0.380938205193939, 0.419978678851639, 0.411908108409114, 0.342961136833629, 0.352390695407995, 0.392589155420387]

    // mocks for testing formula sources
    class TestQtcFormulas: QTcFormulaSource {
        static func qtcCalculator(formula: Formula) -> QTcCalculator {
            return QTcCalculator(formula: formula, longName: "TestLongName", shortName: "TestShortName", reference: "TestReference", equation: "TestEquation", baseEquation: { x, y, sex, age in x + y}, classification: .other, publicationDate: "1901")
        }
    }
    
    class TestQtpFormulas: QTpFormulaSource {
        static func qtpCalculator(formula: Formula) -> QTpCalculator {
            return QTpCalculator(formula: formula, longName: "TestLongName", shortName: "TestShortName", reference: "TestReference", equation: "TestEquation", baseEquation: {x, sex, age in pow(x, 2.0)}, classification: .other)
        }
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testConversions() {
        // sec <-> msec conversions
        XCTAssertEqual(QTc.secToMsec(1), 1000)
        XCTAssertEqual(QTc.secToMsec(2), 2000)
        XCTAssertEqual(QTc.msecToSec(1000), 1)
        XCTAssertEqual(QTc.msecToSec(2000), 2)
        XCTAssertEqual(QTc.msecToSec(0), 0)
        XCTAssertEqual(QTc.secToMsec(0), 0)
        XCTAssertEqual(QTc.msecToSec(2000), 2)                
        XCTAssertEqual(QTc.msecToSec(1117), 1.117, accuracy: delta)
        
        // bpm <-> sec conversions
        XCTAssertEqual(QTc.bpmToSec(1), 60)
        // Swift divide by zero doesn't throw
        XCTAssertNoThrow(QTc.bpmToSec(0))
        XCTAssert(QTc.bpmToSec(0).isInfinite)
        XCTAssertEqual(QTc.bpmToSec(0), Double.infinity)
        XCTAssertEqual(QTc.bpmToSec(0.333), 180.18018018018, accuracy: delta)
        
        // bpm <-> msec conversions
        // we'll check published conversion table with rough accuracy
        // source: https://link.springer.com/content/pdf/bfm%3A978-3-642-58810-5%2F1.pdf
        XCTAssertEqual(QTc.bpmToMsec(215), 279, accuracy: veryRoughDelta)
        for (rate, interval) in rateIntervalTable {
            XCTAssertEqual(QTc.bpmToMsec(rate), interval, accuracy: veryRoughDelta)
            XCTAssertEqual(QTc.msecToBpm(interval), rate, accuracy: veryVeryRoughDelta)
        }
    }
    
    func testQTcFunctions() {
        // QTcBZT (Bazett)
        let qtcBzt = QTc.qtcCalculator(formula: .qtcBzt)
        XCTAssertEqual(try! qtcBzt.calculate(qtInSec:0.3, rrInSec:1.0), 0.3, accuracy: delta)
        XCTAssertEqual(try! qtcBzt.calculate(qtInMsec:300, rrInMsec:1000), 300, accuracy:delta)
        XCTAssertEqual(try! qtcBzt.calculate(qtInSec: 0.3, rate: 60), 0.3, accuracy: delta)
        XCTAssertEqual(try! qtcBzt.calculate(qtInMsec: 300, rate: 60), 300, accuracy: delta)
        for (qt, interval, qtc) in qtcBztTable {
            XCTAssertEqual(try! qtcBzt.calculate(qtInMsec: qt, rrInMsec: interval), qtc, accuracy: veryRoughDelta)
        }
        XCTAssertEqual(try! qtcBzt.calculate(qtInMsec: 456, rate: 77), 516.6, accuracy: roughDelta)
        XCTAssertEqual(try! qtcBzt.calculate(qtInMsec: 369, rrInMsec: 600), 476.4, accuracy: roughDelta)
        XCTAssertEqual(try! qtcBzt.calculate(qtInSec: 2.78, rate: 88), 3.3667, accuracy: roughDelta)
        XCTAssertEqual(try! qtcBzt.calculate(qtInSec: 2.78, rrInSec: QTc.bpmToSec(88)), 3.3667, accuracy: roughDelta)
        XCTAssertEqual(try! qtcBzt.calculate(qtInSec: 5.0, rrInSec: 0), Double.infinity)
        XCTAssertEqual(try! qtcBzt.calculate(qtInSec: 5.0, rrInSec: 0), Double.infinity)
        
        // QTcFRD (Fridericia)
        let qtcFrd = QTc.qtcCalculator(formula: .qtcFrd)
        XCTAssertEqual(try! qtcFrd.calculate(qtInMsec: 456, rate: 77), 495.5, accuracy: roughDelta)
        XCTAssertEqual(try! qtcFrd.calculate(qtInMsec: 369, rrInMsec: 600), 437.5, accuracy: roughDelta)
        XCTAssertEqual(try! qtcFrd.calculate(qtInSec: 2.78, rate: 88), 3.1586, accuracy: roughDelta)
        XCTAssertEqual(try! qtcFrd.calculate(qtInSec: 2.78, rrInSec: QTc.bpmToSec(88)), 3.1586, accuracy: roughDelta)
        
        // run through multiple QTcs
        let qtcFrm = QTc.qtcCalculator(formula: .qtcFrm)
        let qtcHdg = QTc.qtcCalculator(formula: .qtcHdg)
        for (rate, rrInSec, rrInMsec, qtInMsec, qtcBztResult, qtcFrdResult, qtcFrmResult, qtcHdgResult) in qtcMultipleTable {
            // all 4 forms of QTc calculation are tested for each calculation
            // QTcBZT
            XCTAssertEqual(try! qtcBzt.calculate(qtInMsec: qtInMsec, rate: rate), qtcBztResult, accuracy: roughDelta)
            XCTAssertEqual(try! qtcBzt.calculate(qtInSec: QTc.msecToSec(qtInMsec), rrInSec: rrInSec), QTc.msecToSec(qtcBztResult), accuracy: roughDelta)
            XCTAssertEqual(try! qtcBzt.calculate(qtInMsec: qtInMsec, rrInMsec: rrInMsec), qtcBztResult, accuracy: roughDelta)
            XCTAssertEqual(try! qtcBzt.calculate(qtInSec: QTc.msecToSec(qtInMsec), rate: rate), QTc.msecToSec(qtcBztResult), accuracy: roughDelta)
            
            // QTcFRD
            XCTAssertEqual(try! qtcFrd.calculate(qtInMsec: qtInMsec, rate: rate), qtcFrdResult, accuracy: roughDelta)
            XCTAssertEqual(try! qtcFrd.calculate(qtInSec: QTc.msecToSec(qtInMsec), rrInSec: rrInSec), QTc.msecToSec(qtcFrdResult), accuracy: roughDelta)
            XCTAssertEqual(try! qtcFrd.calculate(qtInMsec: qtInMsec, rrInMsec: rrInMsec), qtcFrdResult, accuracy: roughDelta)
            XCTAssertEqual(try! qtcFrd.calculate(qtInSec: QTc.msecToSec(qtInMsec), rate: rate), QTc.msecToSec(qtcFrdResult), accuracy: roughDelta)
            
            
            // QTcFRM
            XCTAssertEqual(try! qtcFrm.calculate(qtInMsec: qtInMsec, rate: rate), qtcFrmResult, accuracy: roughDelta)
            XCTAssertEqual(try! qtcFrm.calculate(qtInSec: QTc.msecToSec(qtInMsec), rrInSec: rrInSec), QTc.msecToSec(qtcFrmResult), accuracy: roughDelta)
            XCTAssertEqual(try! qtcFrm.calculate(qtInMsec: qtInMsec, rrInMsec: rrInMsec), qtcFrmResult, accuracy: roughDelta)
            XCTAssertEqual(try! qtcFrm.calculate(qtInSec: QTc.msecToSec(qtInMsec), rate: rate), QTc.msecToSec(qtcFrmResult), accuracy: roughDelta)
            
            // QTcHDG
            XCTAssertEqual(try! qtcHdg.calculate(qtInMsec: qtInMsec, rate: rate), qtcHdgResult, accuracy: roughDelta)
            XCTAssertEqual(try! qtcHdg.calculate(qtInSec: QTc.msecToSec(qtInMsec), rrInSec: rrInSec), QTc.msecToSec(qtcHdgResult), accuracy: roughDelta)
            XCTAssertEqual(try! qtcHdg.calculate(qtInMsec: qtInMsec, rrInMsec: rrInMsec), qtcHdgResult, accuracy: roughDelta)
            XCTAssertEqual(try! qtcHdg.calculate(qtInSec: QTc.msecToSec(qtInMsec), rate: rate), QTc.msecToSec(qtcHdgResult), accuracy: roughDelta)
            
        }
        
        // handle zero RR
        XCTAssertEqual(try! qtcBzt.calculate(qtInSec: 300, rrInSec: 0), Double.infinity)
        XCTAssertEqual(try! qtcFrd.calculate(qtInSec: 300, rrInSec: 0), Double.infinity)
        // handle zero QT and RR
        XCTAssert(try! qtcFrd.calculate(qtInMsec: 0, rrInMsec: 0).isNaN)
        // handle negative RR
        XCTAssert(try! qtcBzt.calculate(qtInMsec: 300, rrInMsec: -100).isNaN)
        
        // QTcRTHa
        let qtcRtha = QTc.qtcCalculator(formula: .qtcRtha)
        XCTAssertEqual(try! qtcRtha.calculate(qtInSec: 0.444, rate: 58.123), 0.43937, accuracy: delta)
        
        // QTcMyd
        let qtcMyd = QTc.qtcCalculator(formula: .qtcMyd)
        XCTAssertEqual(try! qtcMyd.calculate(qtInSec: 0.399, rrInSec: 0.788), 0.46075606, accuracy: delta)
        
        // QTcArr
        let qtcArr = QTc.qtcCalculator(formula: .qtcArr)
        XCTAssertEqual(try! qtcArr.calculate(qtInSec: 0.275, rate: 69), 0.295707844, accuracy: delta)
        
        // Run through more multiple QTcs
        let qtcKwt = QTc.qtcCalculator(formula: .qtcKwt)
        let qtcDmt = QTc.qtcCalculator(formula: .qtcDmt)
        for (qtInSec, rrInSec, qtcMydResult, qtcRthaResult, qtcArrResult, qtcKwtResult, qtcDmtResult) in qtcRandomTable {
            XCTAssertEqual(try! qtcMyd.calculate(qtInSec: qtInSec, rrInSec: rrInSec), qtcMydResult, accuracy: delta)
            XCTAssertEqual(try! qtcRtha.calculate(qtInSec: qtInSec, rrInSec: rrInSec), qtcRthaResult, accuracy: delta)
            XCTAssertEqual(try! qtcArr.calculate(qtInSec: qtInSec, rrInSec: rrInSec), qtcArrResult, accuracy: delta)
            XCTAssertEqual(try! qtcKwt.calculate(qtInSec: qtInSec, rrInSec: rrInSec), qtcKwtResult, accuracy: delta)
            XCTAssertEqual(try! qtcDmt.calculate(qtInSec: qtInSec, rrInSec: rrInSec), qtcDmtResult, accuracy: delta)
        }
        
    }
    
    // Most QTc functions will have QTc == QT at HR 60 (RR 1000 msec)
    func testEquipose() {
        let sampleQTs = [0.345, 1.0, 0.555, 0.114, 0, 0.888]
        // Subset of QTc formulae, only including non-exponential formulas
        let formulas: [Formula] = [.qtcBzt, .qtcFrd, .qtcHdg, .qtcFrm, .qtcMyd, .qtcRtha]
        
        for formula in formulas {
            let qtc = QTc.qtcCalculator(formula: formula)
            for qt in sampleQTs {
                XCTAssertEqual(try! qtc.calculate(qtInSec: qt, rrInSec: 1.0), qt)
            }
        }
    }
    
    func testNewFormulas() {
        let qtcYos = QTc.qtcCalculator(formula: .qtcYos)
        // QTcYOS is pediatric formula and throws if age not given or age is adult
        XCTAssertEqual(try! qtcYos.calculate(qtInSec: 0.421, rrInSec: 1.34, age: 14), 0.384485183352,
                       accuracy: delta)
        XCTAssertThrowsError(try qtcYos.calculate(qtInSec: 0.421, rate: 1.34))
        XCTAssertThrowsError(try qtcYos.calculate(qtInSec: 0.421, rate: 1.34, age: 21))
    }
    
    func testNewQTpFormulas() {
        let qtpBdl = QTc.qtpCalculator(formula: .qtpBdl)
        XCTAssertEqual(try! qtpBdl.calculate(rate: 60, sex: .male), 0.401, accuracy: delta)
        XCTAssertEqual(try! qtpBdl.calculate(rate: 99, sex: .female), 0.3328, accuracy: delta)
        let qtpAsh = QTc.qtpCalculator(formula: .qtpAsh)
        XCTAssertEqual(try! qtpAsh.calculate(rate: 60, sex: .female, age: 20), 0.396312754411, accuracy: delta)
        XCTAssertThrowsError(try qtpAsh.calculate(rrInSec: 0.8))
        XCTAssertThrowsError(try qtpAsh.calculate(rrInSec: 0.8, sex: .male))
        XCTAssertThrowsError(try qtpAsh.calculate(rrInSec: 0.8, age: 55))
    }
    
    func testQTcConvert() {
        let qtcBzt = QTc.qtcCalculator(formula: .qtcBzt)
        let qtcHdg = QTc.qtcCalculator(formula: .qtcHdg)
        let qtcRtha = QTc.qtcCalculator(formula: .qtcRtha)
        let qtcFrm = QTc.qtcCalculator(formula: .qtcFrm)
        XCTAssertEqual(try! qtcBzt.calculate(qtInMsec: 356.89, rrInMsec: 891.32), QTc.secToMsec(try! qtcBzt.calculate(qtInSec: 0.35689, rrInSec: 0.89132)))
        XCTAssertEqual(try! qtcHdg.calculate(qtInSec: 0.299, rrInSec: 0.5), QTc.msecToSec(try! qtcHdg.calculate(qtInMsec: 299, rate: 120)))
        XCTAssertEqual(try! qtcRtha.calculate(qtInSec: 0.489, rate: 78.9), QTc.msecToSec(try! qtcRtha.calculate(qtInMsec: 489, rate: 78.9)))
        XCTAssertEqual(try! qtcFrm.calculate(qtInMsec: 843, rrInMsec: 300), try! qtcFrm.calculate(qtInMsec: 843, rate: 200))
    }
    
    
    func testQTpConvert() {
        let qtpArr = QTc.qtpCalculator(formula: .qtpArr)
        XCTAssertEqual(try! qtpArr.calculate(rrInSec: 0.253), QTc.msecToSec(try! qtpArr.calculate(rrInMsec: 253)))
        XCTAssertEqual(try! qtpArr.calculate(rrInSec: 0.500), try! qtpArr.calculate(rate: 120))
    }
    
    func testMockSourceFormulas() {
        let qtcTest = QTc.qtcCalculator(formulaSource: TestQtcFormulas.self, formula: .qtcBzt)
        XCTAssertEqual(qtcTest.formula, .qtcBzt)
        XCTAssertEqual(qtcTest.longName, "TestLongName")
        XCTAssertEqual(qtcTest.shortName, "TestShortName")
        XCTAssertEqual(qtcTest.reference, "TestReference")
        XCTAssertEqual(qtcTest.equation, "TestEquation")
        XCTAssertEqual(qtcTest.publicationDate, "1901")
        XCTAssertEqual(try! qtcTest.calculate(qtInSec: 5, rrInSec: 7), 12)
        
        let qtpTest = QTc.qtpCalculator(formulaSource: TestQtpFormulas.self, formula: .qtpArr)
        XCTAssertEqual(qtpTest.formula, .qtpArr)
        XCTAssertEqual(qtpTest.longName, "TestLongName")
        XCTAssertEqual(qtpTest.shortName, "TestShortName")
        XCTAssertEqual(qtpTest.reference, "TestReference")
        XCTAssertEqual(qtpTest.equation, "TestEquation")
        XCTAssertEqual(qtpTest.publicationDate, nil)
        XCTAssertEqual(try! qtpTest.calculate(rrInSec: 5), 25)
    }
    
    func testShortNames() {
        let qtcBzt = QTc.qtcCalculator(formula: .qtcBzt)
        let qtpArr = QTc.qtpCalculator(formula: .qtpArr)
        XCTAssertEqual(qtcBzt.shortName, "QTcBZT")
        XCTAssertEqual(qtpArr.shortName, "QTpARR")
    }
    
    func testSexFormulas() {
        let calculator = QTc.qtcCalculator(formula: .qtcAdm)
        let qt = 0.888
        let rr = 0.678
        let qtcUnspecifiedSex = try! calculator.calculate(qtInSec: qt, rrInSec: rr, sex: .unspecified, age: 55)
        let qtcMale = try! calculator.calculate(qtInSec: qt, rrInSec: rr, sex: .male, age: 60)
        let qtcFemale = try! calculator.calculate(qtInSec: 0.888, rrInSec: rr, sex: .female, age: 99)
        XCTAssertEqual(qtcUnspecifiedSex, 0.9351408, accuracy: delta)
        XCTAssertEqual(qtcMale, 0.9374592, accuracy: delta)
        XCTAssertEqual(qtcFemale, 0.9285398, accuracy: delta)
        
    }
    
    func testClassification() {
        let qtcBzt = QTc.qtcCalculator(formula: .qtcBzt)
        XCTAssertEqual(qtcBzt.classification, .power)
        let qtcFrm = QTc.qtcCalculator(formula: .qtcFrm)
        XCTAssertEqual(qtcFrm.classification, .linear)
    }
    
    func testNewCalculate() {
        let qtcBzt = QTc.calculator(formula: .qtcBzt, formulaType: .qtc)
        var qtMeasurement = QtMeasurement(qt: 370.0, intervalRate: 1000, units: .msec, intervalRateType: .interval, sex: .unspecified, age: nil)
        XCTAssertEqual(try? qtcBzt.calculate(qtMeasurement: qtMeasurement), 370.0)
        let qtpBzt = QTc.calculator(formula: .qtpBzt, formulaType: .qtp)
        qtMeasurement = QtMeasurement(qt: 370.0, intervalRate: 1000, units: .msec, intervalRateType: .interval, sex: .female, age: nil)
        XCTAssertEqual(try? qtpBzt.calculate(qtMeasurement: qtMeasurement), 400.0)
        let qtcFrd = QTc.calculator(formula: .qtcFrd)
        XCTAssertEqual(try? qtcFrd.calculate(qtMeasurement: qtMeasurement), 370.0)
        
    }
    
    func testFormulaTypes() {
        let qtcBzt = QTc.calculator(formula: .qtcBzt, formulaType: .qtc)
        XCTAssert(qtcBzt.formula == .qtcBzt)
        XCTAssert(qtcBzt.formula.formulaType() == .qtc)
        // .qtcTest not member of QTc or QTp set of formulas
        // However can't test this, as it leads to assertionFailure and program halt
        //let qtcTst = QTc.calculator(formula: .qtcTest, formulaType: .qtc)
        //XCTAssertThrowsError(qtcTst.formula?.formulaType())
    }
    
    func testAbnormalQTc() {
        var qtcTest = QTcTest(value: 440, units: .msec, valueComparison: .greaterThan)
        var measurement = QTcMeasurement(qtc: 441, units: .msec)
        XCTAssertTrue(qtcTest.isAbnormal(qtcMeasurement: measurement))
        measurement = QTcMeasurement(qtc: 439, units: .msec)
        XCTAssertFalse(qtcTest.isAbnormal(qtcMeasurement: measurement))
        measurement = QTcMeasurement(qtc: 440, units: .msec)
        XCTAssertFalse(qtcTest.isAbnormal(qtcMeasurement: measurement))
        measurement = QTcMeasurement(qtc: 0.439, units: .sec)
        XCTAssertFalse(qtcTest.isAbnormal(qtcMeasurement: measurement))
        measurement = QTcMeasurement(qtc: 0.441, units: .sec)
        XCTAssertTrue(qtcTest.isAbnormal(qtcMeasurement: measurement))
        qtcTest = QTcTest(value: 440, units: .msec, valueComparison: .greaterThanOrEqual)
        measurement = QTcMeasurement(qtc: 440, units: .msec)
        XCTAssertTrue(qtcTest.isAbnormal(qtcMeasurement: measurement))
        qtcTest = QTcTest(value: 350, units: .msec, valueComparison: .lessThanOrEqual)
        measurement = QTcMeasurement(qtc: 350, units: .msec)
        XCTAssertTrue(qtcTest.isAbnormal(qtcMeasurement: measurement))
        measurement = QTcMeasurement(qtc: 351, units: .msec)
        XCTAssertFalse(qtcTest.isAbnormal(qtcMeasurement: measurement))
        
        qtcTest = QTcTest(value: 350, units: .msec, valueComparison: .lessThanOrEqual, sex: .female)
        measurement = QTcMeasurement(qtc: 311, units: .msec)
        XCTAssertFalse(qtcTest.isAbnormal(qtcMeasurement: measurement))
        measurement = QTcMeasurement(qtc: 311, units: .msec, sex: .male)
        XCTAssertFalse(qtcTest.isAbnormal(qtcMeasurement: measurement))
        measurement = QTcMeasurement(qtc: 311, units: .msec, sex: .female)
        XCTAssertTrue(qtcTest.isAbnormal(qtcMeasurement: measurement))
        
        qtcTest = QTcTest(value: 350, units: .msec, valueComparison: .lessThanOrEqual, sex: .female, age: 18, ageComparison: .lessThan)
        measurement = QTcMeasurement(qtc: 311, units: .msec, sex: .female)
        XCTAssertFalse(qtcTest.isAbnormal(qtcMeasurement: measurement))
        measurement = QTcMeasurement(qtc: 311, units: .msec, sex: .female, age: 15)
        XCTAssertTrue(qtcTest.isAbnormal(qtcMeasurement: measurement))
        
        var testSuite = QTcTestSuite(name: "test", qtcTests: [qtcTest], reference: "test", description: "test")
        var result = testSuite.abnormalQTcTests(qtcMeasurement: measurement)
        XCTAssertEqual(result.count, 1)
        XCTAssertTrue(result[0].severity == .abnormal)
        XCTAssertEqual(testSuite.severity(measurement: measurement), .abnormal)
        
        
        measurement = QTcMeasurement(qtc: 355, units: .msec, sex: .female, age: 15)
        result = testSuite.abnormalQTcTests(qtcMeasurement: measurement)
        XCTAssertEqual(result.count, 0)
        XCTAssertEqual(testSuite.severity(measurement: measurement), .normal)
        
        let qtcTest2 = QTcTest(value: 440, units: .msec, valueComparison: .greaterThan, severity: .moderate)
        testSuite = QTcTestSuite(name: "test2", qtcTests: [qtcTest, qtcTest2], reference: "test", description: "test")
        measurement = QTcMeasurement(qtc: 500, units: .msec)
        XCTAssertEqual(testSuite.severity(measurement: measurement), .moderate)
    }
    
    func testAbnormalQTcCriteria() {
        if let testSuite = AbnormalQTc.qtcTestSuite(criterion: .schwartz1985) {
            var measurement = QTcMeasurement(qtc: 445, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .abnormal)
            XCTAssert(testSuite.severity(measurement: measurement).isAbnormal())
            measurement = QTcMeasurement(qtc: 0.439, units: .sec)
            XCTAssertFalse(testSuite.severity(measurement: measurement).isAbnormal())
        }
        if let testSuite = AbnormalQTc.qtcTestSuite(criterion: .fda2005) {
            var measurement = QTcMeasurement(qtc: 455, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .mild)
            measurement = QTcMeasurement(qtc: 485, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .moderate)
            measurement = QTcMeasurement(qtc: 600, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .severe)
            measurement = QTcMeasurement(qtc: 450, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .normal)
        }
        if let testSuite = AbnormalQTc.qtcTestSuite(criterion: .aha2009) {
            var measurement = QTcMeasurement(qtc: 450, units: .msec, sex: .male)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .abnormal)
            measurement = QTcMeasurement(qtc: 460, units: .msec, sex: .female)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .abnormal)
            // we leave out the sex here to get undefined value
            measurement = QTcMeasurement(qtc: 460, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .undefined)
            measurement = QTcMeasurement(qtc: 459, units: .msec, sex: .female)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .normal)
            measurement = QTcMeasurement(qtc: 390, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .undefined)
        }
        if let testSuite = AbnormalQTc.qtcTestSuite(criterion: .esc2005) {
            var measurement = QTcMeasurement(qtc: 450, units: .msec, sex: .male)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .abnormal)
            measurement = QTcMeasurement(qtc: 460, units: .msec, sex: .female)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .normal)
            measurement = QTcMeasurement(qtc: 461, units: .msec, sex: .female)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .abnormal)
            // we leave out the sex here to make sure we get an undefined value
            measurement = QTcMeasurement(qtc: 461, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .undefined)
            measurement = QTcMeasurement(qtc: 459, units: .msec, sex: .female)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .normal)
            measurement = QTcMeasurement(qtc: 290, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: measurement), .undefined)
        }
        if let testSuite = AbnormalQTc.qtcTestSuite(criterion: .goldenberg2006) {
            var m = QTcMeasurement(qtc: 445, units: .msec) // requires age and sex
            XCTAssertEqual(testSuite.severity(measurement: m), .undefined)
            m = QTcMeasurement(qtc: 445, units: .msec, sex: .male)
            XCTAssertEqual(testSuite.severity(measurement: m), .undefined)
            m = QTcMeasurement(qtc: 445, units: .msec, sex: .male, age: 20)
            XCTAssertEqual(testSuite.severity(measurement: m), .borderline)
            m = QTcMeasurement(qtc: 461, units: .msec, sex: .female, age: 10)
            XCTAssertEqual(testSuite.severity(measurement: m), .abnormal)
            m = QTcMeasurement(qtc: 461, units: .msec, sex: .female, age: 16)
            XCTAssertEqual(testSuite.severity(measurement: m), .borderline)
            m = QTcMeasurement(qtc: 461, units: .msec, sex: .male, age: 16)
            XCTAssertEqual(testSuite.severity(measurement: m), .abnormal)
        }
        if let testSuite = AbnormalQTc.qtcTestSuite(criterion: .schwartz1993) {
            var m = QTcMeasurement(qtc: 445, units: .msec) // requires sex
            XCTAssertEqual(testSuite.severity(measurement: m), .undefined)
            m = QTcMeasurement(qtc: 445, units: .msec, sex: .male)
            XCTAssertEqual(testSuite.severity(measurement: m), .normal)
            m = QTcMeasurement(qtc: 445, units: .msec, sex: .male, age: 20)
            XCTAssertEqual(testSuite.severity(measurement: m), .normal)
            m = QTcMeasurement(qtc: 461, units: .msec, sex: .female, age: 10)
            XCTAssertEqual(testSuite.severity(measurement: m), .moderate)
            m = QTcMeasurement(qtc: 461, units: .msec, sex: .female, age: 16)
            XCTAssertEqual(testSuite.severity(measurement: m), .moderate)
            m = QTcMeasurement(qtc: 451, units: .msec, sex: .male, age: 16)
            XCTAssertEqual(testSuite.severity(measurement: m), .mild)
            m = QTcMeasurement(qtc: 451, units: .msec, sex: .female, age: 16)
            XCTAssertEqual(testSuite.severity(measurement: m), .normal)
        }
        // test short QTc
        if let testSuite = AbnormalQTc.qtcTestSuite(criterion: .gollob2011) {
            var m = QTcMeasurement(qtc: 0.345, units: .sec)
            XCTAssertEqual(testSuite.severity(measurement: m), .moderate)
            m = QTcMeasurement(qtc: 315, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: m), .severe)
            m = QTcMeasurement(qtc: 370, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: m), .normal)
            m = QTcMeasurement(qtc: 369.99999, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: m), .mild)
        }
        if let testSuite = AbnormalQTc.qtcTestSuite(criterion: .mazzanti2014) {
            var m = QTcMeasurement(qtc: 360, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: m), .borderline)
            m = QTcMeasurement(qtc: 335, units: .msec)
            XCTAssertEqual(testSuite.severity(measurement: m), .abnormal)
        }
        
    }
    
    // TODO: test new QTc and QTp formulas
    func testQTp() {
        var calculator: QTpCalculator = QTc.qtpCalculator(formula: .qtpBzt)
        var i = 0
        for interval in rrIntervals {
            XCTAssertEqual(try calculator.calculate(rrInSec: interval, sex: .male), qtpBztMaleResults[i], accuracy: delta)
            XCTAssertEqual(try calculator.calculate(rrInSec: interval, sex: .female), qtpBztFemaleResults[i], accuracy: delta)
            i += 1
        }
        calculator = QTc.qtpCalculator(formula: .qtpFrd)
        i = 0
        for interval in rrIntervals {
            XCTAssertEqual(try calculator.calculate(rrInSec: interval), qtpFrdResults[i], accuracy: delta)
            i += 1
        }
        calculator = QTc.qtpCalculator(formula: .qtpHdg)
        i = 0
        for interval in rrIntervals {
            XCTAssertEqual(try calculator.calculate(rrInSec: interval), qtpHdgResults[i], accuracy: delta)
            i += 1
        }
        calculator = QTc.qtpCalculator(formula: .qtpMyd)
        i = 0
        for interval in rrIntervals {
            XCTAssertEqual(try calculator.calculate(rrInSec: interval), qtpMydResults[i], accuracy: delta)
            i += 1
        }
        calculator = QTc.qtpCalculator(formula: .qtpKrj)
        i = 0
        for interval in rrIntervals {
            if interval > 1.0 {
                XCTAssertEqual(qtpKrjSlowResults[i], try calculator.calculate(rrInSec: interval), accuracy: delta)
            }
            else if interval <= 0.6 {
                XCTAssertEqual(qtpKrjFastResults[i], try calculator.calculate(rrInSec: interval), accuracy: delta)
            }
            else {
                XCTAssertEqual(qtpKrjMediumResults[i], try calculator.calculate(rrInSec: interval), accuracy: delta)
            }
            i += 1
        }
        calculator = QTc.qtpCalculator(formula: .qtpSch)
        i = 0
        for interval in rrIntervals {
            XCTAssertEqual(try calculator.calculate(rrInSec: interval), qtpSchResults[i], accuracy: delta)
            i += 1
        }
        calculator = QTc.qtpCalculator(formula: .qtpAdm)
        i = 0
        for interval in rrIntervals {
            XCTAssertEqual(try calculator.calculate(rrInSec: interval, sex: .male), qtpAdmMenResults[i], accuracy: delta)
            XCTAssertEqual(try calculator.calculate(rrInSec: interval, sex: .female), qtpAdmWomenResults[i], accuracy: delta)
            XCTAssertEqual(try calculator.calculate(rrInSec: interval, sex: .unspecified), qtpAdmCombinedResults[i], accuracy: delta)
            i += 1
        }
        calculator = QTc.qtpCalculator(formula: .qtpSmn)
        i = 0
        for interval in rrIntervals {
            XCTAssertEqual(try calculator.calculate(rrInSec: interval, age: ages[i]), qtpSmnResults[i], accuracy: delta)
            i += 1
        }
        // make sure QTpSMN throws if no age given
        XCTAssertThrowsError(try calculator.calculate(rrInSec: 0.4))
        calculator = QTc.qtpCalculator(formula: .qtpKwt)
        i = 0
        for interval in rrIntervals {
            XCTAssertEqual(try calculator.calculate(rrInSec: interval, age: ages[i]), qtpKwtResults[i], accuracy: delta)
            i += 1
        }
        // NB: in between ages with extrapolated constants not tested here, but are tested in the Rabkin tests.
        calculator = QTc.qtpCalculator(formula: .qtpScl)
        i = 0
        for interval in rrIntervals {
            if ages[i] < 20 {
                i += 1
                continue
            }
            if ages[i] < 30 {
                XCTAssertEqual(try calculator.calculate(rrInSec: interval, age: ages[i]), qtpScl20to40Results[i], accuracy: delta)
            }
            else if ages[i] < 50  && ages[i] > 40 {
                XCTAssertEqual(try calculator.calculate(rrInSec: interval, age: ages[i]), qtpScl40to60Results[i], accuracy: delta)
            }
            else if ages[i] < 70  && ages[i] > 60 {
                XCTAssertEqual(try calculator.calculate(rrInSec: interval, age: ages[i]), qtpScl60to70Results[i], accuracy: delta)
            }
            else if ages[i] > 70 {
                XCTAssertEqual(try calculator.calculate(rrInSec: interval, age: ages[i]), qtpSclOver70Results[i], accuracy: delta)
            }
            i += 1
        }
        XCTAssertThrowsError(try calculator.calculate(rate: 60))
        XCTAssertThrowsError(try calculator.calculate(rate: 60, age: 15))
        calculator = QTc.qtpCalculator(formula: .qtpMrr)
        i = 0
        for interval in rrIntervals {
            XCTAssertEqual(try calculator.calculate(rrInSec: interval), qtpMrrCombinedResults[i], accuracy: delta)
            XCTAssertEqual(try calculator.calculate(rrInSec: interval, sex: .male), qtpMrrMaleResults[i], accuracy: delta)
            XCTAssertEqual(try calculator.calculate(rrInSec: interval, sex: .female), qtpMrrFemaleResults[i], accuracy: delta)
            i += 1
        }
        calculator = QTc.qtpCalculator(formula: .qtpHgg)
        i = 0
        for interval in rrIntervals {
            XCTAssertEqual(try calculator.calculate(rrInSec: interval), qtpHggResults[i], accuracy: delta)
            i += 1
        }
        calculator = QTc.qtpCalculator(formula: .qtpGot)
        i = 0
        for interval in rrIntervals {
            XCTAssertEqual(try calculator.calculate(rrInSec: interval), qtpGotResults[i], accuracy: delta)
            i += 1
        }
        calculator = QTc.qtpCalculator(formula: .qtpKlg)
        i = 0
        for interval in rrIntervals {
            XCTAssertEqual(try calculator.calculate(rrInSec: interval), qtpKlgResults[i], accuracy: delta)
            i += 1
        }
        calculator = QTc.qtpCalculator(formula: .qtpShp)
        i = 0
        for interval in rrIntervals {
            XCTAssertEqual(try calculator.calculate(rrInSec: interval, sex: .male), qtpShpMaleResults[i], accuracy: delta)
            XCTAssertEqual(try calculator.calculate(rrInSec: interval, sex: .female), qtpShpFemaleResults[i], accuracy: delta)
            i += 1
        }
        XCTAssertThrowsError(try calculator.calculate(rrInSec: 0.4))
        calculator = QTc.qtpCalculator(formula: .qtpWhl)
        i = 0
        for interval in rrIntervals {
            XCTAssertEqual(try calculator.calculate(rrInSec: interval, sex: .female), qtpWhlResults[i], accuracy: delta)
            i += 1
        }
        calculator = QTc.qtpCalculator(formula: .qtpAsh)
        i = 0
        for interval in rrIntervals {
            XCTAssertEqual(try calculator.calculate(rrInSec: interval, sex: .female, age: 12), qtpAshChildrenResults[i], accuracy: delta)
            XCTAssertEqual(try calculator.calculate(rrInSec: interval, sex: .female, age: 40), qtpAshWomen40Results[i], accuracy: delta)
            XCTAssertEqual(try calculator.calculate(rrInSec: interval, sex: .female, age: 77), qtpAshOldWomenResults[i], accuracy: delta)
            XCTAssertEqual(try calculator.calculate(rrInSec: interval, sex: .male, age: 46), qtpAshOldMenResults[i], accuracy: delta)
            i += 1
        }
        calculator = QTc.qtpCalculator(formula: .qtpSrm)
        i = 0
        for interval in rrIntervals {
            XCTAssertEqual(try calculator.calculate(rrInSec: interval, sex: .female), qtpSrmResults[i], accuracy: delta)
            i += 1
        }
        calculator = QTc.qtpCalculator(formula: .qtpLcc)
        i = 0
        for interval in rrIntervals {
            XCTAssertEqual(try calculator.calculate(rrInSec: interval, sex: .female), qtpLccResults[i], accuracy: delta)
            i += 1
        }
    }
    
    func testQTc() {
        var qtcCalculator = QTc.qtcCalculator(formula: .qtcRthb)
        var i = 0
        for interval in rrIntervals {
            XCTAssertEqual(try qtcCalculator.calculate(qtInSec: qtIntervals[i], rrInSec: interval, sex: .male, age: nil), qtcRthbMaleResults[i], accuracy: delta)
            
            XCTAssertEqual(try qtcCalculator.calculate(qtInSec: qtIntervals[i], rrInSec: interval, sex: .female, age: nil), qtcRthbFemaleResults[i], accuracy: delta)
            i += 1
        }
        qtcCalculator = QTc.qtcCalculator(formula: .qtcYos)
        i = 0
        for interval in rrIntervals {
            XCTAssertEqual(try qtcCalculator.calculate(qtInSec: qtIntervals[i], rrInSec: interval, age: 15), qtcYosResults[i], accuracy: delta)
            i += 1
        }
        qtcCalculator = QTc.qtcCalculator(formula: .qtcGot)
        i = 0
        for interval in rrIntervals {
            XCTAssertEqual(try qtcCalculator.calculate(qtInSec: qtIntervals[i], rrInSec: interval), qtcGotResults[i], accuracy: delta)
            i += 1
        }
    }

    func testCutoffs() {
        let test = AbnormalQTc.qtcTestSuite(criterion: .schwartz1985)
        let cutoffs = test?.cutoffs(units: .sec)
        XCTAssertEqual(cutoffs![0].value, 0.44)
        let cutoffsMsec = test?.cutoffs(units: .msec)
        XCTAssertEqual(cutoffsMsec![0].value, 440.0)
    }

    typealias formulaTest = (formula: Formula, result: Double)
    typealias formulaTests = [formulaTest]

    private func rabkinTest(results: formulaTests, qtMeasurement: QtMeasurement, accuracy: Double = 0.1) {
        for result in results {
            print(QTc.calculator(formula: result.formula).shortName + " ," + String((try!QTc.calculator(formula: result.formula).calculate(qtMeasurement: qtMeasurement))) + ", " + String(result.result))
            XCTAssertEqual(round(try! QTc.calculator(formula: result.formula).calculate(qtMeasurement: qtMeasurement)), result.result, accuracy: accuracy)
        }
    }

    func testRabkinResults() {
        // Note that the QTcDMT in Rabkin appears to use a formula with a typo: the exponent he uses in 0.473 rather than 0.413.  So we have corrected his result for QTcDMT here.  Rabkin has 437 for QTcDMT.  It should be 438.
        let results1: formulaTests = [(.qtcFrm, 439.0), (.qtcHdg, 441.0), (.qtcRtha, 439.0), (.qtcBzt, 437.0), (.qtcFrd, 439.0), (.qtcMyd, 435.0), (.qtcKwt, 440.0), (.qtcDmt, 438.0), (.qtcGot, 439.0), (.qtcRthb, 439.0)]
        let qtMeasurement = QtMeasurement(qt: 444.0, intervalRate: 58, units: .msec, intervalRateType: .rate, sex: .male, age: 71)
        rabkinTest(results: results1, qtMeasurement: qtMeasurement)
        let results2: formulaTests = [(.qtpAdm, 405), (.qtpSch, 379), (.qtpKrj, 397), (.qtpSmn, 408), (.qtpBdl, 405), (.qtpHdg, 395), (.qtpWhl, 388), (.qtpKlg, 404), (.qtpBzt, 376), (.qtpFrd, 386), (.qtpMyd, 424), (.qtpScl, 388), (.qtpShp, 404), (.qtpHgg, 397), (.qtpKwt, 454), (.qtpGot, 440), (.qtpAsh, 396), (.qtpMrr, 423), (.qtpSrm, 467), (.qtpLcc, 410), (.qtpArr, 425)]
        rabkinTest(results: results2, qtMeasurement: qtMeasurement)

        let qtMeasurement2 = QtMeasurement(qt: 354, intervalRate: 107, units: .msec, intervalRateType: .rate, sex: .male, age: 53)
        
        let results3: formulaTests = [(.qtcFrm, 422), (.qtcHdg, 436), (.qtcRtha, 446), (.qtcBzt, 473), (.qtcFrd, 429), (.qtcMyd, 502), (.qtcKwt, 409), (.qtcDmt, 450), (.qtcGot, 431), (.qtcRthb, 429)]
        rabkinTest(results: results3, qtMeasurement: qtMeasurement2)
        let results4: formulaTests = [(.qtpAdm, 332), (.qtpSch, 282), (.qtpKrj, 314), (.qtpSmn, 337), (.qtpBdl, 307), (.qtpHdg, 309), (.qtpWhl, 327), (.qtpKlg, 340), (.qtpBzt, 277), (.qtpFrd, 315), (.qtpMyd, 293), (.qtpScl, 309), (.qtpShp, 297), (.qtpHgg, 292), (.qtpKwt, 389), (.qtpGot, 357), (.qtpAsh, 304), (.qtpMrr, 323), (.qtpSrm, 362), (.qtpLcc, 340), (.qtpArr, 325)]
        rabkinTest(results: results4, qtMeasurement: qtMeasurement2)

        let qtMeasurment3 = QtMeasurement(qt: 384, intervalRate: 89, units: .msec, intervalRateType: .rate, sex: .female, age: 53)

        let results5: formulaTests = [(.qtcFrm, 434), (.qtcHdg, 435), (.qtcRtha, 446), (.qtcBzt, 468), (.qtcFrd, 438), (.qtcMyd, 487), (.qtcKwt, 424), (.qtcDmt, 452), (.qtcGot, 439), (.qtcRthb, 442)]
        rabkinTest(results: results5, qtMeasurement: qtMeasurment3)
        let results6: formulaTests = [(.qtpAdm, 364), (.qtpSch, 305), (.qtpKrj, 341), (.qtpSmn,353), (.qtpBdl, 351), (.qtpHdg, 340), (.qtpWhl, 350), (.qtpKlg, 364), (.qtpBzt, 328), (.qtpFrd, 335), (.qtpMyd, 327), (.qtpScl, 329), (.qtpShp, 341), (.qtpHgg, 320), (.qtpKwt, 408), (.qtpGot, 380), (.qtpAsh, 340), (.qtpMrr, 364), (.qtpSrm, 400), (.qtpLcc, 369), (.qtpArr, 357)]
        rabkinTest(results: results6, qtMeasurement: qtMeasurment3)
        // Simonson tests
        let qtMesaurement4 = QtMeasurement(qt: 430, intervalRate: 1180, units: .msec, intervalRateType: .interval, sex: .male, age: 55)
        let results7: formulaTests = [(.qtpBzt, 400), (.qtpShp, 430), (.qtpScl, 400), (.qtpAsh, 420), (.qtpSch, 410), (.qtpMyd, 450), (.qtpSmn, 420)]
        rabkinTest(results: results7, qtMeasurement: qtMesaurement4, accuracy: 10.0)
        let qtMesaurement5 = QtMeasurement(qt: 340, intervalRate: 660, units: .msec, intervalRateType: .interval, sex: .male, age: 45)
        let results8: formulaTests = [(.qtpBzt, 300), (.qtpShp, 320), (.qtpScl, 320), (.qtpAsh, 330), (.qtpSch, 310), (.qtpMyd, 320), (.qtpSmn, 350)]
        rabkinTest(results: results8, qtMeasurement: qtMesaurement5, accuracy: 10.0)
        let qtMesaurement6 = QtMeasurement(qt: 370, intervalRate: 840, units: .msec, intervalRateType: .interval, sex: .male, age: 25)
        let results9: formulaTests = [(.qtpBzt, 340), (.qtpShp, 360), (.qtpScl, 350), (.qtpAsh, 350), (.qtpSch, 340), (.qtpMyd, 370), (.qtpSmn, 370)]
        rabkinTest(results: results9, qtMeasurement: qtMesaurement6, accuracy: 10.0)
    }

    func testQtcRbk() {
        XCTAssertEqual(QtcRbk.b1(60), 0.05552338, accuracy: delta)
        XCTAssertEqual(QtcRbk.b1(80), 0)
        XCTAssertEqual(QtcRbk.b2(60), 0.4502079, accuracy: delta)
        XCTAssertEqual(QtcRbk.b2(80), 0)
        XCTAssertEqual(QtcRbk.b3(60), 0.4942118, accuracy: delta)
        XCTAssertEqual(QtcRbk.b3(80), 0.0004464286, accuracy: delta)
    }

}
