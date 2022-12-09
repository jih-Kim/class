package Entity;

import javax.persistence.*;
import org.springframework.data.annotation.Id;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;



@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Table {

    //not javax but springframework data
    @Id
    //javax
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long channel_id;

    private String cellName;

    private String status;

    private int cycle;

    private long current;

    private long Voltage;

    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name="Cap_id")
    private Capacity capacity;

    private long energyChange;

    private long cycleLife;
}
