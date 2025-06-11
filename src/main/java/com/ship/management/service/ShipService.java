package com.ship.management.service;

import com.ship.management.dto.ShipDTO;
import com.ship.management.entity.Ship;
import com.ship.management.repository.ShipRepository;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ShipService {

    private final ShipRepository shipRepository;
    private final ModelMapper modelMapper;

    public Page<ShipDTO> getAllShips(Pageable pageable) {
        Page<Ship> ships = shipRepository.findAll(pageable);
        return ships.map(this::convertToDTO);
    }

    public Optional<ShipDTO> getShipById(Long id) {
        return shipRepository.findById(id)
                .map(this::convertToDTO);
    }

    public Optional<ShipDTO> getShipByName(String name) {
        return shipRepository.findByName(name)
                .map(this::convertToDTO);
    }

    public ShipDTO createShip(ShipDTO shipDTO) {
        Ship ship = convertToEntity(shipDTO);
        ship.setId(null); // Ensure it's a new entity
        Ship savedShip = shipRepository.save(ship);
        return convertToDTO(savedShip);
    }

    public Optional<ShipDTO> updateShip(Long id, ShipDTO shipDTO) {
        return shipRepository.findById(id)
                .map(existingShip -> {
                    existingShip.setName(shipDTO.getName());
                    existingShip.setDescription(shipDTO.getDescription());
                    Ship updatedShip = shipRepository.save(existingShip);
                    return convertToDTO(updatedShip);
                });
    }

    public boolean deleteShip(Long id) {
        if (shipRepository.existsById(id)) {
            shipRepository.deleteById(id);
            return true;
        }
        return false;
    }

    private ShipDTO convertToDTO(Ship ship) {
        return modelMapper.map(ship, ShipDTO.class);
    }

    private Ship convertToEntity(ShipDTO shipDTO) {
        return modelMapper.map(shipDTO, Ship.class);
    }
} 