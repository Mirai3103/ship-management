package com.ship.management.entity;

import java.time.LocalDate;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "review_plan")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReviewPlan {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name")
    private String name;

    @Column(name = "description")
    private String description;
    
    private LocalDate date;

    @ManyToOne
    @JoinColumn(name = "created_by")
    private User createdBy;

    private String status;
    private String type;

    @ManyToOne
    @JoinColumn(name = "ship_id")
    private Ship ship;

}
