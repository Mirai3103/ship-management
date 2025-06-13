package com.ship.management.repository;

import com.ship.management.entity.Ship;
import com.ship.management.entity.User;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ShipRepository extends JpaRepository<Ship, Long> {

    
    Optional<Ship> findByName(String name);
    @Query("SELECT s.users FROM Ship s WHERE s.id = :shipId")

    List<User> findUsersByShipId(Long shipId);

}
