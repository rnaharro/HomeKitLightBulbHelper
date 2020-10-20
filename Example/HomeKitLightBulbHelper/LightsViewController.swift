import UIKit
import HomeKit
import HomeKitLightBulbHelper

class LightsViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    var helper: HomeKitHelper?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "BulbTableViewCell", bundle: nil), forCellReuseIdentifier: "bulbCell")
        helper = HomeKitHelper(didUpdateHomes: { [weak self] in
            self?.tableView.delegate = self
            self?.tableView.dataSource = self
            self?.tableView.reloadData()
        })
    }
}

extension LightsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        helper?.numberOfRooms() ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let helper = helper, let room = helper.room(at: section) {
            return helper.numberOfBulbs(for: room)
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "bulbCell") else {
            return UITableViewCell()
        }

        cell.accessoryType = .none

        let room = (helper?.room(at: indexPath.section))!
        let bulbs = (helper?.lightBulbs(room: room))!
        let title = cell.contentView.viewWithTag(10) as? UILabel
        title?.text = bulbs[indexPath.row].name

        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        30
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        view.backgroundColor = .black
        let label = UILabel(frame: view.bounds)
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 24)
        label.text = helper?.nameForRoom(at: section)
        label.translatesAutoresizingMaskIntoConstraints = true
        view.addSubview(label)
        return view
    }

}
