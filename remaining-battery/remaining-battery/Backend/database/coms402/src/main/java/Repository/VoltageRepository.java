package Repository;

import org.springframework.data.jpa.repository.JpaRepository;
import Entity.Voltage;

public interface VoltageRepository extends JpaRepository<Voltage,Long> {
    
}
