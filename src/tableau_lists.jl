
function run_list_vprk_glrk(iode)
    run_list(iode, :TableauVPRK, (
            ( TableauVPGLRK(1),          "vprk_glrk1" ),
            ( TableauVPGLRK(2),          "vprk_glrk2" ),
            ( TableauVPGLRK(3),          "vprk_glrk3" ),
            ( TableauVPGLRK(4),          "vprk_glrk4" ),
            ( TableauVPGLRK(5),          "vprk_glrk5" ),
            ( TableauVPGLRK(6),          "vprk_glrk6" ),
        ))
end

function run_list_vprk_lobatto_IIIA_IIIB(iode)
    run_list(iode, :TableauVPRK, (
            ( TableauVPLobIIIA2(),    "vprk_lobatto_IIIA_IIIB2" ),
            ( TableauVPLobIIIA3(),    "vprk_lobatto_IIIA_IIIB3" ),
            ( TableauVPLobIIIA4(),    "vprk_lobatto_IIIA_IIIB4" ),
            ( TableauVPLobIIIA5(),    "vprk_lobatto_IIIA_IIIB5" ),
        ))
end

function run_list_vprk_lobatto_IIIB_IIIA(iode)
    run_list(iode, :TableauVPRK, (
            ( TableauVPLobIIIB2(),    "vprk_lobatto_IIIB_IIIA2" ),
            ( TableauVPLobIIIB3(),    "vprk_lobatto_IIIB_IIIA3" ),
            ( TableauVPLobIIIB4(),    "vprk_lobatto_IIIB_IIIA4" ),
            ( TableauVPLobIIIB5(),    "vprk_lobatto_IIIB_IIIA5" ),
        ))
end

function run_list_vprk_radau(iode)
    run_list(iode, :TableauVPRK, (
            ( TableauVPRadIIAIIA2(),     "vprk_radau_IIA2" ),
            ( TableauVPRadIIAIIA3(),     "vprk_radau_IIA3" ),
        ))
end

function run_list_srk_glrk(iode)
    run_list(iode, :TableauFIRK, (
            ( getTableauGLRK(1),          "srk_glrk1",      IntegratorSRKimplicit ),
            ( getTableauGLRK(2),          "srk_glrk2",      IntegratorSRKimplicit ),
            ( getTableauGLRK(3),          "srk_glrk3",      IntegratorSRKimplicit ),
            ( getTableauGLRK(4),          "srk_glrk4",      IntegratorSRKimplicit ),
            ( getTableauGLRK(5),          "srk_glrk5",      IntegratorSRKimplicit ),
            ( getTableauGLRK(6),          "srk_glrk6",      IntegratorSRKimplicit ),
        ))
end

function run_list_firk_glrk(iode)
    run_list(iode, :TableauFIRK, (
            ( getTableauGLRK(1),          "firk_glrk1",     IntegratorFIRKimplicit ),
            ( getTableauGLRK(2),          "firk_glrk2",     IntegratorFIRKimplicit ),
            ( getTableauGLRK(3),          "firk_glrk3",     IntegratorFIRKimplicit ),
            ( getTableauGLRK(4),          "firk_glrk4",     IntegratorFIRKimplicit ),
            ( getTableauGLRK(5),          "firk_glrk5",     IntegratorFIRKimplicit ),
            ( getTableauGLRK(6),          "firk_glrk6",     IntegratorFIRKimplicit ),
        ))
end
