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

    mapping(bytes32 => bool) public votantesHabilitados;
    mapping(bytes32 => bool) public haVotado;

    event VotanteHabilitado(bytes32 hashVotante);
    event VotoEmitido(bytes32 hashVotante, uint256 opcionId);

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

    function generarHashVotante(address _votante) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_votante));
    }

    function habilitarVotante(address _votante) public soloAdministrador {
        bytes32 hashVotante = generarHashVotante(_votante);

        votantesHabilitados[hashVotante] = true;

        emit VotanteHabilitado(hashVotante);
    }

    function votar(uint256 _opcionId) public {
        bytes32 hashVotante = generarHashVotante(msg.sender);

        require(votantesHabilitados[hashVotante], "No estas habilitado para votar");
        require(!haVotado[hashVotante], "Ya emitiste tu voto");
        require(_opcionId < opciones.length, "Opcion invalida");

        opciones[_opcionId].votos++;
        haVotado[hashVotante] = true;

        emit VotoEmitido(hashVotante, _opcionId);
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

    function consultarSiVoto(address _votante) public view returns (bool) {
        bytes32 hashVotante = generarHashVotante(_votante);
        return haVotado[hashVotante];
    }

    function consultarSiEstaHabilitado(address _votante) public view returns (bool) {
        bytes32 hashVotante = generarHashVotante(_votante);
        return votantesHabilitados[hashVotante];
    }
}