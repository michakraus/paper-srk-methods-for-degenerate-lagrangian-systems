
function tableaus_vprk_glrk()
    (
        ( TableauVPGLRK(1),          "vprk_glrk1" ),
        ( TableauVPGLRK(2),          "vprk_glrk2" ),
        ( TableauVPGLRK(3),          "vprk_glrk3" ),
        ( TableauVPGLRK(4),          "vprk_glrk4" ),
        ( TableauVPGLRK(5),          "vprk_glrk5" ),
        ( TableauVPGLRK(6),          "vprk_glrk6" ),
    )
end

function tableaus_vprk_lobatto_IIIA_IIIB()
    (
        ( TableauVPLobattoIIIA(2),    "vprk_lobatto_IIIA_IIIB2" ),
        ( TableauVPLobattoIIIA(3),    "vprk_lobatto_IIIA_IIIB3" ),
        ( TableauVPLobattoIIIA(4),    "vprk_lobatto_IIIA_IIIB4" ),
        ( TableauVPLobattoIIIA(5),    "vprk_lobatto_IIIA_IIIB5" ),
    )
end

function tableaus_vprk_lobatto_IIIB_IIIA()
    (
        ( TableauVPLobattoIIIB(2),    "vprk_lobatto_IIIB_IIIA2" ),
        ( TableauVPLobattoIIIB(3),    "vprk_lobatto_IIIB_IIIA3" ),
        ( TableauVPLobattoIIIB(4),    "vprk_lobatto_IIIB_IIIA4" ),
        ( TableauVPLobattoIIIB(5),    "vprk_lobatto_IIIB_IIIA5" ),
    )
end

function tableaus_vprk_radau()
    (
        ( TableauVPRadauIIAIIA(2),     "vprk_radau_IIA2" ),
        ( TableauVPRadauIIAIIA(3),     "vprk_radau_IIA3" ),
        ( TableauVPRadauIIAIIA(4),     "vprk_radau_IIA4" ),
        ( TableauVPRadauIIAIIA(5),     "vprk_radau_IIA5" ),
    )
end

function tableaus_srk_glrk()
    (
        ( TableauGLRK(1),          "srk_glrk1",      IntegratorSRKimplicit ),
        ( TableauGLRK(2),          "srk_glrk2",      IntegratorSRKimplicit ),
        ( TableauGLRK(3),          "srk_glrk3",      IntegratorSRKimplicit ),
        ( TableauGLRK(4),          "srk_glrk4",      IntegratorSRKimplicit ),
        ( TableauGLRK(5),          "srk_glrk5",      IntegratorSRKimplicit ),
        ( TableauGLRK(6),          "srk_glrk6",      IntegratorSRKimplicit ),
    )
end

function tableaus_firk_glrk()
    (
        ( TableauGLRK(1),          "firk_glrk1",     IntegratorFIRKimplicit ),
        ( TableauGLRK(2),          "firk_glrk2",     IntegratorFIRKimplicit ),
        ( TableauGLRK(3),          "firk_glrk3",     IntegratorFIRKimplicit ),
        ( TableauGLRK(4),          "firk_glrk4",     IntegratorFIRKimplicit ),
        ( TableauGLRK(5),          "firk_glrk5",     IntegratorFIRKimplicit ),
        ( TableauGLRK(6),          "firk_glrk6",     IntegratorFIRKimplicit ),
    )
end
