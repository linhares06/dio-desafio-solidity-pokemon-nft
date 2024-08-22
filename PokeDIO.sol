// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract PokeDIO is ERC721 {

    enum ElementType { Fire, Water, Grass }

    struct Pokemon {
        string name;
        uint level;
        string img;
        ElementType elementType;
        uint experience;
    }

    Pokemon[] public pokemons;
    address public gameOwner;

    constructor () ERC721("PokeDIO", "PKD") {
        gameOwner = msg.sender;
    }

    modifier onlyOwnerOf(uint _pokemonId) {
        require(ownerOf(_pokemonId) == msg.sender, "Apenas o dono pode batalhar com este Pokemon");
        _;
    }

    // Define type advantage logic
    function getTypeAdvantage(ElementType attackerType, ElementType defenderType) internal pure returns (uint) {
        if (attackerType == ElementType.Fire && defenderType == ElementType.Grass) {
            return 2;
        } else if (attackerType == ElementType.Grass && defenderType == ElementType.Water) {
            return 2;
        } else if (attackerType == ElementType.Water && defenderType == ElementType.Fire) {
            return 2;
        }
        return 1;
    }

    function battle(uint _attackingPokemon, uint _defendingPokemon) public onlyOwnerOf(_attackingPokemon) {
        Pokemon storage attacker = pokemons[_attackingPokemon];
        Pokemon storage defender = pokemons[_defendingPokemon];

        uint typeAdvantage = getTypeAdvantage(attacker.elementType, defender.elementType);

        if (attacker.level * typeAdvantage >= defender.level) {
            attacker.experience += 10 * typeAdvantage;
            defender.experience += 5;
        } else {
            attacker.experience += 5;
            defender.experience += 10 * typeAdvantage;
        }

        // Level up logic
        if (attacker.experience >= 100) {
            attacker.level += 1;
            attacker.experience = 0;
        }

        if (defender.experience >= 100) {
            defender.level += 1;
            defender.experience = 0;
        }
    }

    function createNewPokemon(string memory _name, address _to, string memory _img, ElementType _elementType) public {
        require(msg.sender == gameOwner, "Apenas o dono do jogo pode criar novos Pokemons");
        uint id = pokemons.length;
        pokemons.push(Pokemon(_name, 1, _img, _elementType, 0));
        _safeMint(_to, id);
    }
}