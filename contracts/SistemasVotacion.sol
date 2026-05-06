// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SistemaVotacion {

    struct Opcion {
        uint256 id;
        string nombre;
        uint256 votos;
    }

    address public administrador;

    Opcion[] public opciones;

    mapping(address => bool) public votantesHabilitados;
    mapping(address => bool) public haVotado;

    event VotanteHabilitado(address votante);
    event VotoEmitido(address votante, uint256 opcionId);

    constructor() {
        administrador = msg.sender;

        opciones.push(Opcion(0, "Candidato A", 0));
        opciones.push(Opcion(1, "Candidato B", 0));
        opciones.push(Opcion(2, "Candidato C", 0));
    }

    modifier soloAdministrador() {
        require(msg.sender == administrador, "Solo el administrador puede realizar esta accion");
        _;
    }

    function habilitarVotante(address _votante) public soloAdministrador {
        votantesHabilitados[_votante] = true;
        emit VotanteHabilitado(_votante);
    }

    function votar(uint256 _opcionId) public {
        require(votantesHabilitados[msg.sender], "No estas habilitado para votar");
        require(!haVotado[msg.sender], "Ya emitiste tu voto");
        require(_opcionId < opciones.length, "Opcion invalida");

        opciones[_opcionId].votos++;
        haVotado[msg.sender] = true;

        emit VotoEmitido(msg.sender, _opcionId);
    }

    function consultarVotos(uint256 _opcionId) public view returns (uint256) {
        require(_opcionId < opciones.length, "Opcion invalida");
        return opciones[_opcionId].votos;
    }

    function cantidadOpciones() public view returns (uint256) {
        return opciones.length;
    }

    function obtenerOpcion(uint256 _opcionId) public view returns (uint256, string memory, uint256) {
        require(_opcionId < opciones.length, "Opcion invalida");

        Opcion memory opcion = opciones[_opcionId];
        return (opcion.id, opcion.nombre, opcion.votos);
    }
}