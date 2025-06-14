package com.ship.management.entity;

import java.time.LocalDateTime;
import java.util.List;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "checklist")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChecklistItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String content;

    private String guide;

    private String orderNo;



    @ManyToOne
    @JoinColumn(name = "checklist_template_id")
    private ChecklistTemplate checklistTemplate;

    @ManyToOne
    @JoinColumn(name = "assigned_to")
    private User assignedTo;

    @Column(name = "vessel_result")
    private String vesselResult;

    @Column(name = "vessel_remark")
    private String vesselRemark;

    @ManyToOne
    @JoinColumn(name = "com_assigned_to")
    private User comAssignedTo;

    @Column(name = "com_result")
    private String comResult;

    @Column(name = "com_remark")
    private String comRemark;

    private LocalDateTime comReviewAt = null;

    private LocalDateTime vesselReviewAt = null;

    @Column(name = "note")
    private String note;

    @Column(name = "status")
    private String status;

    @OneToMany(mappedBy = "checklistItem", cascade = CascadeType.ALL, orphanRemoval = true,fetch = FetchType.EAGER)
    private List<Attachment> attachments;
    

    

}
