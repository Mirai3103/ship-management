package com.ship.management.entity;

import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.Data;

import java.util.List;
import java.util.Objects;

import jakarta.persistence.Entity;

@Entity
@Table(name = "checklist_template")
@Data
public class ChecklistTemplate {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String section;
    private int orderNo=0;

    @OneToMany(mappedBy = "checklistTemplate")
    private List<ChecklistItem> checklistItems;
    
    @ManyToOne
    @JoinColumn(name = "review_plan_id",nullable = true)
    private ReviewPlan reviewPlan;

    @ManyToOne
    @JoinColumn(name = "ship_id")
    private Ship ship;

    @ManyToOne
    @JoinColumn(name = "company_id", referencedColumnName = "id",nullable = false)
    private Company company;
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ChecklistTemplate that = (ChecklistTemplate) o;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
