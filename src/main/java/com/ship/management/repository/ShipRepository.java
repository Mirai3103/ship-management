package com.ship.management.repository;

import com.ship.management.entity.Ship;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ShipRepository extends JpaRepository<Ship, Long> {

    List<Ship> findByType(String type);
    
    Optional<Ship> findByName(String name);
    

}
