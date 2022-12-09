package Repository;

import org.springframework.data.jpa.repository.JpaRepository;

import Entity.CycleLife;

public interface CycleLifeRepository extends JpaRepository<CycleLife,Long> {
    
}
