
function tableaus_vprk_glrk()
    (
        ( VPRKGauss(1),          "vprk_gauss1" ),
        ( VPRKGauss(2),          "vprk_gauss2" ),
        ( VPRKGauss(3),          "vprk_gauss3" ),
        ( VPRKGauss(4),          "vprk_gauss4" ),
        ( VPRKGauss(5),          "vprk_gauss5" ),
        ( VPRKGauss(6),          "vprk_gauss6" ),
    )
end

function tableaus_vprk_lobatto_IIIA_IIIB()
    (
        ( VPRKLobattoIIIAIIIB(2),    "vprk_lobatto_IIIA_IIIB2" ),
        ( VPRKLobattoIIIAIIIB(3),    "vprk_lobatto_IIIA_IIIB3" ),
        ( VPRKLobattoIIIAIIIB(4),    "vprk_lobatto_IIIA_IIIB4" ),
        ( VPRKLobattoIIIAIIIB(5),    "vprk_lobatto_IIIA_IIIB5" ),
    )
end

function tableaus_vprk_lobatto_IIIB_IIIA()
    (
        ( VPRKLobattoIIIBIIIA(2),    "vprk_lobatto_IIIB_IIIA2" ),
        ( VPRKLobattoIIIBIIIA(3),    "vprk_lobatto_IIIB_IIIA3" ),
        ( VPRKLobattoIIIBIIIA(4),    "vprk_lobatto_IIIB_IIIA4" ),
        ( VPRKLobattoIIIBIIIA(5),    "vprk_lobatto_IIIB_IIIA5" ),
    )
end

function tableaus_vprk_radau()
    (
        ( VPRKRadauIIA(2),     "vprk_radau_IIA2" ),
        ( VPRKRadauIIA(3),     "vprk_radau_IIA3" ),
        ( VPRKRadauIIA(4),     "vprk_radau_IIA4" ),
        ( VPRKRadauIIA(5),     "vprk_radau_IIA5" ),
    )
end

function tableaus_srk_glrk()
    (
        ( DVRK(Gauss(1)),          "srk_gauss1" ),
        ( DVRK(Gauss(2)),          "srk_gauss2" ),
        ( DVRK(Gauss(3)),          "srk_gauss3" ),
        ( DVRK(Gauss(4)),          "srk_gauss4" ),
        ( DVRK(Gauss(5)),          "srk_gauss5" ),
        ( DVRK(Gauss(6)),          "srk_gauss6" ),
    )
end

function tableaus_firk_glrk()
    (
        ( Gauss(1),          "firk_gauss1" ),
        ( Gauss(2),          "firk_gauss2" ),
        ( Gauss(3),          "firk_gauss3" ),
        ( Gauss(4),          "firk_gauss4" ),
        ( Gauss(5),          "firk_gauss5" ),
        ( Gauss(6),          "firk_gauss6" ),
    )
end
