package com.ship.management.service;

import com.ship.management.dto.EditShipUserDTO;
import com.ship.management.dto.ShipDTO;
import com.ship.management.dto.ShipQueryDTO;
import com.ship.management.dto.UserDTO;
import com.ship.management.entity.Company;
import com.ship.management.entity.Ship;
import com.ship.management.entity.User;
import com.ship.management.entity.Role.RootRole;
import com.ship.management.repository.CompanyRepository;
import com.ship.management.repository.ShipRepository;
import com.ship.management.repository.UserRepository;
import com.ship.management.specification.ShipSpecification;

import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ShipService {

    private final ShipRepository shipRepository;
    private final ModelMapper modelMapper;
    private final CompanyRepository companyRepository;
    private final UserRepository userRepository;
    private final UserService userService;

    public Page<ShipDTO> getAllShips(Pageable pageable, ShipQueryDTO queryDTO) {
        var rootRole = userService.getCurrentUserRootRole();
        var currentUser = userService.getCurrentUser();
        
        Specification<Ship> spec = Specification.where(ShipSpecification.withQuery(queryDTO));
        
        if (RootRole.ADMIN.equals(rootRole)) {
            // Admin có thể xem tất cả ships
            Page<Ship> ships = shipRepository.findAll(spec, pageable);
            return ships.map(this::convertToDTO);
        }
        
        // Nếu strict = true, chỉ lấy ships mà user được assign
        if (Boolean.TRUE.equals(queryDTO.getStrict())) {
            spec = spec.and(ShipSpecification.withUserId(currentUser.getId()));
            Page<Ship> ships = shipRepository.findAll(spec, pageable);
            return ships.map(this::convertToDTO);
        }
        
        // Nếu strict = false, lấy tất cả ships của company
        spec = spec.and(ShipSpecification.withCompanyId(currentUser.getCompany().getId()));
        Page<Ship> ships = shipRepository.findAll(spec, pageable);
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
        Company company = companyRepository.findById(shipDTO.getCompanyId())
                .orElseThrow(() -> new RuntimeException("Công ty không tồn tại"));
        ship.setCompany(company);
        Ship savedShip = shipRepository.save(ship);
        return convertToDTO(savedShip);
    }

    public Optional<ShipDTO> updateShip(Long id, ShipDTO shipDTO) {
        return shipRepository.findById(id)
                .map(existingShip -> {
                    existingShip.setName(shipDTO.getName());
                    existingShip.setDescription(shipDTO.getDescription());
                    Company company = companyRepository.findById(shipDTO.getCompanyId())
                            .orElseThrow(() -> new RuntimeException("Công ty không tồn tại"));
                    existingShip.setCompany(company);
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

    public List<UserDTO> getUsersByShipId(Long shipId) {
        return shipRepository.findUsersByShipId(shipId).stream()
                .map(user -> modelMapper.map(user, UserDTO.class))
                .collect(Collectors.toList());
    }

    public void editShipUsers(EditShipUserDTO editShipUserDTO) {
        Ship ship = shipRepository.findById(editShipUserDTO.getShipId())
                .orElseThrow(() -> new RuntimeException("Tàu không tồn tại"));
        List<User> addUsers = userRepository.findByIdIn(editShipUserDTO.getAddUserIds());
        List<User> removeUsers = userRepository.findByIdIn(editShipUserDTO.getRemoveUserIds());
        ship.getUsers().addAll(addUsers);
        ship.getUsers().removeAll(removeUsers);
        shipRepository.save(ship);
    }

    public List<ShipDTO> getShipsByCompanyIdStrict(Long companyId) {
        var rootRole = userService.getCurrentUserRootRole();
        if (RootRole.ADMIN.equals(rootRole)) {
            return shipRepository.findByCompanyId(companyId).stream()
                    .map(this::convertToDTO)
                    .collect(Collectors.toList());
        }
        var userShips = shipRepository.findByUserIdAndCompanyId(userService.getCurrentUser().getId(), companyId);
        return userShips.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<ShipDTO> getShipsByCompanyId(Long companyId) {

            return shipRepository.findByCompanyId(companyId).stream()
                    .map(this::convertToDTO)
                    .collect(Collectors.toList());


    }
}