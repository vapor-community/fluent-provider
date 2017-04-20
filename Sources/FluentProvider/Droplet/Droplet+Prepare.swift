extension Droplet {
    internal func prepare() throws {
        guard config.preparations.count > 0 else {
            log.warning("No preparations detected.")
            log.info("If you want to use models with Fluent, make sure to add the model to the Droplet's preparations array, e.g., `drop.preparations.append(ModelType.self)`.")
            return
        }
        
        let database = try assertDatabase()
        
        if config.arguments.option("revert")?.bool == true {
            if config.arguments.option("all")?.bool == true {
                guard console.confirm("Are you sure you want to revert the entire database?", style: .warning) else {
                    console.error("Reversion cancelled")
                    return
                }
                
                try database.revertAll(config.preparations)
                console.print("Removing metadata")
                try database.revertMetadata()
                console.success("Reversion complete")
            } else {
                let (batch, toBeReverted) = try database.previewRevertBatch(config.preparations)
                let list = toBeReverted.map { "\($0)" }.joined(separator: ", ")
                
                guard toBeReverted.count > 0 else {
                    console.print("Nothing to be reverted")
                    return
                }
                
                guard console.confirm("Are you sure you want to revert batch \(batch) (\(list))?", style: .warning) else {
                    console.error("Reversion cancelled")
                    return
                }
                
                try database.revertBatch(config.preparations)
            }
        } else {
            try database.prepare(config.preparations)
            console.info("Database prepared")
        }
    }
}
