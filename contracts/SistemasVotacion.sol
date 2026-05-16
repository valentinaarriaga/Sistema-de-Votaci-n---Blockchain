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

    // Gobernanza tipo DAO
    mapping(address => bool) public administradoresDAO;
    uint256 public cantidadAdministradoresDAO;
    uint256 public aprobacionesNecesarias;

    mapping(bytes32 => uint256) public cantidadAprobacionesVotante;
    mapping(bytes32 => mapping(address => bool)) public aprobacionesRealizadas;

    event VotanteHabilitado(bytes32 hashVotante);
    event VotoEmitido(bytes32 hashVotante, uint256 opcionId);
    event AdministradorDAOAgregado(address administradorDAO);
    event AprobacionVotante(address administradorDAO, bytes32 hashVotante, uint256 totalAprobaciones);

    constructor() {
        administrador = msg.sender;

        administradoresDAO[msg.sender] = true;
        cantidadAdministradoresDAO = 1;
        aprobacionesNecesarias = 2;

        opciones.push(Opcion(0, "Candidato A", 0));
        opciones.push(Opcion(1, "Candidato B", 0));
        opciones.push(Opcion(2, "Candidato C", 0));
    }

    modifier soloAdministrador() {
        require(msg.sender == administrador, "Solo el administrador principal puede realizar esta accion");
        _;
    }

    modifier soloAdministradorDAO() {
        require(administradoresDAO[msg.sender], "Solo un administrador DAO puede aprobar votantes");
        _;
    }

    function generarHashVotante(address _votante) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_votante));
    }

    function agregarAdministradorDAO(address _nuevoAdministrador) public soloAdministrador {
        require(_nuevoAdministrador != address(0), "Direccion invalida");
        require(!administradoresDAO[_nuevoAdministrador], "Ya es administrador DAO");

        administradoresDAO[_nuevoAdministrador] = true;
        cantidadAdministradoresDAO++;

        emit AdministradorDAOAgregado(_nuevoAdministrador);
    }

    function aprobarVotante(address _votante) public soloAdministradorDAO {
        bytes32 hashVotante = generarHashVotante(_votante);

        require(!votantesHabilitados[hashVotante], "El votante ya esta habilitado");
        require(!aprobacionesRealizadas[hashVotante][msg.sender], "Este administrador ya aprobo al votante");

        aprobacionesRealizadas[hashVotante][msg.sender] = true;
        cantidadAprobacionesVotante[hashVotante]++;

        emit AprobacionVotante(
            msg.sender,
            hashVotante,
            cantidadAprobacionesVotante[hashVotante]
        );

        if (cantidadAprobacionesVotante[hashVotante] >= aprobacionesNecesarias) {
            votantesHabilitados[hashVotante] = true;
            emit VotanteHabilitado(hashVotante);
        }
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

    function consultarAprobaciones(address _votante) public view returns (uint256) {
        bytes32 hashVotante = generarHashVotante(_votante);
        return cantidadAprobacionesVotante[hashVotante];
    }

    function consultarSiEsAdministradorDAO(address _cuenta) public view returns (bool) {
        return administradoresDAO[_cuenta];
    }
}